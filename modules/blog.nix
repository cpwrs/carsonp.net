{config, ...}: let
  port = 8000;
in {
  age.secrets."blog-env".file = ./../secrets/blog-env.age;

  # Runs the blog using a systemd service that starts the node app
  blog = {
    enable = true;
    inherit port;
    secretEnv = config.age.secrets."blog-env".path;
  };

  # Route requests from carsonp.net to the blog
  services.nginx.virtualHosts."carsonp.net" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      recommendedProxySettings = true;
    };
  };
}
