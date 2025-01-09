{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let 
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nil
          python3
          pyright
          typescript-language-server
          python3Packages.fastapi
          python3Packages.uvicorn
          python3Packages.requests
          python3Packages.httpx
        ];
      };

      nixosConfigurations.server = pkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./server.nix ];
      };
    };
}
