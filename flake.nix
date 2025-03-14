{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    agenix = { url = "github:ryantm/agenix"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, agenix, ... }:
    let 
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Python environment
      env = pkgs.python3.withPackages (ps: with ps; [
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
          # Enrypting secrets
          age
          agenix.packages.${system}.default

          # Language servers
          nil
          pyright
          typescript-language-server

          env
        ];
      };
      
      # Server OS configuration for EC2 instance
      nixosConfigurations.server = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          # Make the source code and python env available to the server
          inherit env;
          inherit source;
        };
        modules = [ 
          agenix.nixosModules.default
         ./server.nix 
        ];
      };
    };
}
