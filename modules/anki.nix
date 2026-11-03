{config, ...}: let
  domain = "anki.carsonp.net";
  address = "::1";
  port = 8004;
in {
  age.secrets."anki-password".file = ./../secrets/anki-password.age;

  services.anki-sync-server = {
    enable = true;
    address = address;
    port = port;

    users = [
      {
        username = "carson";
        passwordFile = config.age.secrets."anki-password";
      }
    ];
  };

  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "carsonp.net";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[::1]:${port}";
      recommendedProxySettings = true;
    };
  };
}
