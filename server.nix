{ modulesPath, pkgs, source, pyenv, env, config, ... }:

let
  port = 8000;
  loopback = "127.0.0.1";
  domain = "carsonp.net";
  email = "me@carsonp.net";
  secrets = config.age.secrets.secretenv.path; # Path to decrypted secrets
in
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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLFlimfo5Wwn7aL4MjHAkQ8FRB3ifif6oa7HqYGt852 me@carsonp.net" # My local desktop
        ];
        extraGroups = [ "wheel" ];
      };
    };
  };

  # Decrypt secret env vars 
  age.secrets = {
    "secretenv" = {
      file = ./secrets/prodenv.age;
    };
  };

  # Start app locally with a systemd service
  systemd.services.web-app = {
    description = "carsonp.net HTTP server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      User = "carson";
      Group = "users";
      ExecStart = "${pyenv}/bin/python3 backend.py --port ${toString port} --host ${loopback}";
      WorkingDirectory = "${source}/lib";
      EnvironmentFile = secrets; # For secret prod env vars 
      Environment = env; # For public prod env vars
    };
  };

  # Reverse proxy to route traffic to app @ 127.0.0.1:8000
  services.nginx = {
    enable = true;

    virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;

      locations."/" = {
        proxyPass = "http://${loopback}:${toString port}";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real_IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };

  # Auto domain validation and certificate retrieval with Let's Encrypt
  security.acme = {
    acceptTerms = true;
    defaults.email = email;
  };

  # Allow HTTP, HTTPS, SSH connections
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 22 ];
    };
  };

  system.stateVersion = "24.11";
}
