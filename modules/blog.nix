{config, ...}: {
  age.secrets."blog.env".file = ./../secrets/blog.env.age;

  # Runs the blog using a systemd service that starts the node app
  blog = {
    enable = true;
    port = 8000;
    address = "::1";
    secretEnv = config.age.secrets."blog.env".path;
  };

  # Route requests from carsonp.net to the blog
  services.nginx.virtualHosts."carsonp.net" = {
    useACMEHost = "carsonp.net";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[${config.blog.address}]:${toString config.blog.port}";
      recommendedProxySettings = true;
    };
  };
}
