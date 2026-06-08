{config, ...}: {
  age.secrets."route53.env".file = ./../secrets/route53.env.age;

  # Use nginx as a reverse proxy to direct traffic to web servers on various loopback ports
  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    enable = true;
  };

  # Auto certificate renewal using ACME and the DNS-01
  security.acme = {
    acceptTerms = true;
    defaults.email = "me@carsonp.net";
    certs."carsonp.net" = {
      domain = "carsonp.net";
      extraDomainNames = ["*.carsonp.net"];
      dnsProvider = "route53";
      environmentFile = config.age.secrets."route53.env".path;
      group = "nginx";
    };
  };
}
