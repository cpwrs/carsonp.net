{config, ...}: let
  domain = "rss.carsonp.net";
  fullAddr = "[::1]:8002";
in {
  age.secrets."miniflux.env".file = ./../secrets/miniflux.env.age;

  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    adminCredentialsFile = config.age.secrets."miniflux.env".path;
    config = {
      CREATE_ADMIN = true;
      LISTEN_ADDR = fullAddr;
      BASE_URL = "https://${domain}";
    };
  };

  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "carsonp.net";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${fullAddr}";
      recommendedProxySettings = true;
    };
  };
}
