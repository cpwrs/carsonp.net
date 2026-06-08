{
  # Use nginx as a reverse proxy to direct traffic to web servers on various loopback ports
  services.nginx = {
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    enable = true;
  };

  # Auto domain validation and certificate retrieval with Let's Encrypt
  security.acme = {
    acceptTerms = true;
    defaults.email = "me@carsonp.net";
  };
}
