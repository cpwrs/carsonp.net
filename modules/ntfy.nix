{config, ...}: let
  domain = "ntfy.carsonp.net";
  socketAddr = "[::1]:8003";
in {
  age.secrets."ntfy.env".file = ./../secrets/ntfy.env.age;

  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://${domain}";
      listen-http = socketAddr;
      upstream-base-url = "https://ntfy.sh";
      auth-file = "/var/lib/ntfy/auth.db";
      auth-default-access = "deny-all";
      enable-login = true;
      require-login = true;
      cache-file = "/var/lib/ntfy/cache.db";
      cache-duration = "24h";
    };
    environmentFile = config.age.secrets."ntfy.env".path;
  };

  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "carsonp.net";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${socketAddr}";
      recommendedProxySettings = true;
    };
  };
}
