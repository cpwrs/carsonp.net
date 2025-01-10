{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }:
    let 
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Dev shell for testing app
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nil
          python3
          pyright
          typescript-language-server
          python3Packages.fastapi
          python3Packages.uvicorn
          python3Packages.httpx
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
        specialArgs = { web-app = self.packages.${system}.default; };
        modules = [ ./server.nix ];
      };
    };
}
