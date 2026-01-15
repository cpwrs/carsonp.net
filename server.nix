{
  modulesPath,
  pkgs,
  blog,
  env,
  config,
  ...
}: let
  port = 8000;
  loopback = "127.0.0.1";
  domain = "carsonp.net";
in {
  imports = ["${modulesPath}/virtualisation/amazon-image.nix"];

  # Enable flakes
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings.allowed-users = ["carson"];
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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLFlimfo5Wwn7aL4MjHAkQ8FRB3ifif6oa7HqYGt852 me@carsonp.net" # Desktop user:carson
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzh/HEQgeasLpvfHLPSqDNpxjFwMdTIRjZoLkfKDm8x me@carsonp.net" # Laptop user:carson
        ];
        extraGroups = ["wheel"];
      };
    };
  };

  # Decrypt secret env vars
  age.secrets = {
    "blog-env" = {
      file = ./secrets/blog-env.age;
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
    defaults.email = "me@carsonp.net";
  };

  # Allow HTTP, HTTPS, SSH connections
  networking = {
    firewall = {
      enable = true;
      allowedTCPPorts = [80 443 22];
    };
  };

  blogRuntime = {
    enable = true;
    port = port;
    secretEnv = config.age.secrets.blog-env.path;
    user = "carson";
  };

  system.stateVersion = "25.11";
}
