{config, ...}: let
  domain = "anki.carsonp.net";
  address = "::1";
  port = 8003;
in {
  age.secrets."anki-password".file = ./../secrets/anki-password.age;

  services.anki-sync-server = {
    enable = true;
    address = address;
    port = port;

    users = [
      {
        username = "carson";
        passwordFile = config.age.secrets."anki-password".path;
      }
    ];
  };

  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "carsonp.net";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[${address}]:${toString port}";
      recommendedProxySettings = true;
    };
  };
}
