{ modulesPath, pkgs, web-app, ... }:
{  
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];

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

  # Start app with a systemd service
  systemd.services.web-app = {
    description = "Start carsonp.net HTTP server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "carson";
      Group = "users";
      ExecStart = let
        python = pkgs.python3.withPackages (ps: with ps; [
          fastapi 
          uvicorn 
          httpx 
        ]); 
        in "${python}/bin/uvicorn backend:app --host 0.0.0.0 --port 80";
      WorkingDirectory = "${web-app}/lib";
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    };
  };

  # Allow SSH, HTTPS, HTTP
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 22 ];
    };
  };

  system.stateVersion = "24.11";
}
