{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }:
    let 
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      env = pkgs.python3.withPackages (ps: with ps; [
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
          env
        ];
      };
      
      # Make the source code available to the server as a derivation
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = "source";
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
          inherit env;
          source = self.packages.${system}.default; 
        };
        modules = [ ./server.nix ];
      };
    };
}
