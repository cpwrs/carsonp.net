{
  description = "NixOS configuration, development shell, and deployment script for my hub on the internet";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    blog.url = "github:cpwrs/blog";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "aarch64-linux"
      ];

      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.nixd
            pkgs.alejandra
            pkgs.age
            pkgs.nixos-anywhere
            inputs.agenix.packages.${pkgs.system}.default
          ];
        };

        packages.deploy = pkgs.writeShellApplication {
          name = "deploy";

          runtimeInputs = [
            pkgs.nixos-rebuild
            pkgs.age
            inputs.agenix.packages.${pkgs.system}.default
          ];

          text = ''
            set -euo pipefail
            IP=$(agenix -d secrets/ip.age)

            echo "Deploying to carson@$IP..."

            nixos-rebuild \
              --target-host "carson@$IP" \
              --sudo \
              --flake .#hetzner-hub \
              switch
          '';
        };
      };

      flake.nixosConfigurations.hetzner-hub = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./modules/config.nix
          ./modules/disk.nix
          ./modules/network.nix
          ./modules/carson.nix
          ./modules/blog.nix

          inputs.blog.nixosModules.default
          inputs.agenix.nixosModules.default
          inputs.disko.nixosModules.default
        ];
      };
    };
}
