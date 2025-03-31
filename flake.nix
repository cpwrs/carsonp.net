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

      # Deploy script
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          # Encrypting secrets
          age
          agenix.packages.${system}.default

          # Language servers
          nil
          pyright
          typescript-language-server
          
          # Python app dependencies
          pyenv
        ];
      };
      
      # Server OS configuration for EC2 instance
      nixosConfigurations.server = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          # Make the source code and python env available to the server OS
          inherit pyenv;
          inherit source;

          # Production environment variables
          env = lib.optional (self ? shortRev) "COMMIT=${self.shortRev}" ++ [ "PROD=1" ];
        };
        modules = [ 
          agenix.nixosModules.default
          ./server.nix 
        ];
      };
    };
}
