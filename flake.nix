{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }:
    let 
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      python-env = pkgs.python3.withPackages (ps: with ps; [
        fastapi 
        uvicorn 
        httpx 
      ]); 
    in {
      # Dev shell for testing app
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nil
          pyright
          typescript-language-server
          python-env
        ];
      };
      
      # Make the app code available to the server as a derivation
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "web-app";
        src = ./app;

        installPhase = ''
          # Copy files
          mkdir -p $out/lib
          cp -r . $out/lib/
        '';
      };

      # Server OS configuration for EC2 instance
      nixosConfigurations.server = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit python-env;
          web-app = self.packages.${system}.default; 
        };
        modules = [ ./server.nix ];
      };
    };
}
