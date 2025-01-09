{ modulesPath, pkgs, ... }:
{  
  imports = [ "${modulesPath}/virtualization/amazon-image.nix" ];

  # Enable flakes 
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings.allowed-users = [ "carson" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Add app dependencies
  environment.systemPackages = with pkgs; [
    vim
    python3
    python3Packages.fastapi
    python3Packages.uvicorn
    python3Packages.requests
    python3Packages.httpx
  ];

  # Add me to ssh
  users = {
    users = {
      carson = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLFlimfo5Wwn7aL4MjHAkQ8FRB3ifif6oa7HqYGt852 me@carsonp.net"
        ];
        extraGroups = [ "wheel" ];
      };
    };
  };

  system.stateVersion = "24.11";
}
