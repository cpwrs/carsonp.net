let
  domain = "vault.carsonp.net";
  address = "::1";
  port = 8001;
in {
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    backupDir = "/var/backup/vaultwarden";
    config = {
      ROCKET_ADDRESS = "::1";
      ROCKET_PORT = port;
      DOMAIN = "https://${domain}";
      SIGNUPS_ALLOWED = false;
    };
  };

  systemd.services.vaultwarden.onFailure = ["ntfy-webapp-failure@%n.service"];

  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "carsonp.net";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[${address}]:${toString port}";
      recommendedProxySettings = true;
    };
  };
}
