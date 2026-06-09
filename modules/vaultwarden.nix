let
  domain = "vault.carsonp.net";
  port = 8001;
in {
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    backupDir = "/var/backup/vaultwarden";
    # environmentFile =
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = port;
      DOMAIN = "https://${domain}";
      SIGNUPS_ALLOWED = false;
    };
  };

  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "carsonp.net";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      recommendedProxySettings = true;
    };
  };
}
