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

  # Server utils
  environment.systemPackages = with pkgs; [
    vim
    git
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

  # Start app locally with a systemd service
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
        in "${python}/bin/uvicorn backend:app --host 127.0.0.0 --port 8000";
      WorkingDirectory = "${web-app}/lib";
      EnvironmentFile = "/etc/web-app.env";
    };
  };

  services.nginx = {
    enable = true;

    virtualHosts."carsonp.net" = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:8000";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real_IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };

  security.ACME = {
    acceptTerms = true;
    defaults.email = "crpowers0@gmail.com";
  };

  # Allow SSH, HTTPS, HTTP connections
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 22 ];
    };
  };

  system.stateVersion = "24.11";
}
