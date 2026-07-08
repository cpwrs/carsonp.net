{config, ...}: {
  age.secrets."hetzner.env".file = ./../secrets/hetzner.env.age;

  # Use nginx as a reverse proxy to direct traffic to web servers on various loopback ports
  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    enable = true;

    virtualHosts."_catchall" = {
      default = true;
      useACMEHost = "carsonp.net";
      forceSSL = true;
      locations."/".return = "404";
    };
  };

  # Auto certificate renewal using Let's Encrypt and the DNS-01 challenge
  security.acme = {
    acceptTerms = true;
    defaults.email = "me@carsonp.net";
    certs."carsonp.net" = {
      domain = "carsonp.net";
      extraDomainNames = ["*.carsonp.net"];
      dnsProvider = "hetzner";
      environmentFile = config.age.secrets."hetzner.env".path;
      group = "nginx";
    };
  };
}
