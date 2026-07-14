{
  config,
  pkgs,
  lib,
  ...
}: let
  domain = "ntfy.carsonp.net";
  socketAddr = "[::1]:8003";

  ntfyWebAppFailure = pkgs.writeShellApplication {
    name = "ntfy-webapp-failure";
    runtimeInputs = [pkgs.ntfy-sh pkgs.systemd];
    text = ''
      unit="$1"
      logs="$(
        {
          systemctl status "$unit" --no-pager --full || true
          echo
          journalctl -u "$unit" -n 80 --no-pager -o short-iso || true
        }
      )"

      ntfy publish \
        --token "$NTFY_TOKEN" \
        --title "Failure in $unit" \
        --priority urgent \
        --tags warning \
        "https://${domain}/alerts" \
        "$logs"
    '';
  };
in {
  age.secrets."ntfy.env".file = ./../secrets/ntfy.env.age;
  age.secrets."ntfy-server-token.env".file = ./../secrets/ntfy-server-token.env.age;

  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://${domain}";
      listen-http = socketAddr;
      upstream-base-url = "https://ntfy.sh";
      auth-file = "/var/lib/ntfy-sh/auth.db";
      auth-default-access = "deny-all";
      enable-login = true;
      require-login = true;
      cache-file = "/var/lib/ntfy-sh/cache.db";
      cache-duration = "24h";
      behind-proxy = true;
    };
    environmentFile = config.age.secrets."ntfy.env".path;
  };

  services.nginx.virtualHosts.${domain} = {
    useACMEHost = "carsonp.net";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${socketAddr}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

  systemd.services."ntfy-webapp-failure@" = {
    description = "Send ntfy notification for failed web app (unit %I)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe ntfyWebAppFailure} %I";
      EnvironmentFile = config.age.secrets."ntfy-server-token.env".path;
      NoNewPrivileges = true;
      PrivateTmp = true;
    };
  };
}
