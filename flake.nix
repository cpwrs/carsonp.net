{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    agenix = { url = "github:ryantm/agenix"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, agenix, ... }:
    let 
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;

      # Python environment
      pyenv = pkgs.python3.withPackages (ps: with ps; [
        fastapi 
        uvicorn 
        httpx 
      ]); 

      # Source code
      source = pkgs.stdenv.mkDerivation {
        name = "source";
        src = ./app;

        installPhase = ''
          # Copy files
          mkdir -p $out/lib
          cp -r . $out/lib/
        '';
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          # Language servers
          nil
          pyright
          typescript-language-server
          
          # Python app dependencies
          pyenv
        ];
        
        # Development environment variables
        shellHook = ''
          export PROD=0
        '';
      };

      # Server OS configuration for EC2 instance
      nixosConfigurations.server = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          # Make the source code and python env available to the server OS
          inherit pyenv;
          inherit source;

          # Public production environment variables
          env = lib.optional (self ? shortRev) "COMMIT=${self.shortRev}" ++ [ "PROD=1" ];
        };
        modules = [ 
          agenix.nixosModules.default
          ./server.nix 
        ];
      };

      # Deployment script
      packages.${system}.deploy = pkgs.writeShellApplication {
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
}
