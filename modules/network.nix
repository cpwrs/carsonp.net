let
  loopback = "127.0.0.1";
  domain = "carsonp.net";
in {
  services.nginx = {
    enable = true;
    virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      # Route / to blog (@8000)
      locations."/" = {
        proxyPass = "http://${loopback}:8000";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
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

  networking = {
    # Keep DHCP ownership explicit: only networkd should request IPv4 DHCP.
    useDHCP = false;
    dhcpcd.enable = false;
    # Allow HTTP, HTTPS, SSH connections
    firewall = {
      enable = true;
      allowedTCPPorts = [80 443 22];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Use networkd to set static ipv6, DHCP for ipv4
  systemd.network.enable = true;
  systemd.network.networks."30-enp1s0" = {
    matchConfig.Name = "enp1s0";
    networkConfig.DHCP = "ipv4";
    address = ["2a01:4ff:1f0:b3c5::1/64"];
    routes = [{Gateway = "fe80::1";}];
  };
}
