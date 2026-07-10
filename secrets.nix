let
  carsons = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6HfPXGeHhbygJrzEvvP4G+wV8I//JnW9ce4mz1GDhW carson@toaster"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzh/HEQgeasLpvfHLPSqDNpxjFwMdTIRjZoLkfKDm8x carson@surface"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIWkpjTxptu9AAQSatBe4gHzejFDcUCuXGY/GR4Dzg7v carson@air"
  ];
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOO9+UDPfN0h5c573qVa+yJb+4qf05XHvFmL1fx2iOFL root@nixos";
  all = carsons ++ [server];
in {
  "secrets/blog.env.age".publicKeys = all;
  "secrets/hetzner.env.age".publicKeys = all;
  "secrets/ntfy.env.age".publicKeys = all;
  "secrets/ntfy-server-token.env.age".publicKeys = all;

  # Only developers need ip to deploy.
  "secrets/ip.age".publicKeys = carsons;
}
