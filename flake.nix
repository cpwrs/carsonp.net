{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    blog.url = "github:cpwrs/blog";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    agenix,
    blog,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # Server OS configuration for EC2 instance
    nixosConfigurations.server = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        agenix.nixosModules.default
        blog.nixosModules.default
        ./server.nix
      ];
    };

    # Deployment script
    packages.${system} = {
      deploy = pkgs.writeShellApplication {
        name = "deploy";
        runtimeInputs = with pkgs; [
          nixos-rebuild
          agenix.packages.${system}.default
          age
        ];

        text = ''
          set -e

          # Check if user is an age recipient
          if ! agenix -d secrets/ip.age > /dev/null 2>&1; then
            echo "Error: User does not have deploy privileges. Failed to decrypt secrets."
            exit 1
          fi

          # Grab target private key
          PEM_FILE=$(mktemp)
          agenix -d secrets/pem.age > "$PEM_FILE"
          chmod 600 "$PEM_FILE"

          # Grab target IP
          IP=$(agenix -d secrets/ip.age)

          # Skip confirmation and don't save target info to known_hosts
          export NIX_SSHOPTS="-i $PEM_FILE -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

          echo "Deploying to $IP..."
          # Deploy the NixOS config to target
          nixos-rebuild --target-host "root@$IP" --flake .#server switch
        '';
      };
    };
  };
}
