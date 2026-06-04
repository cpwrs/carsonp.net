{
  users.users.carson = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6HfPXGeHhbygJrzEvvP4G+wV8I//JnW9ce4mz1GDhW carson@toaster"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzh/HEQgeasLpvfHLPSqDNpxjFwMdTIRjZoLkfKDm8x carson@surface"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIWkpjTxptu9AAQSatBe4gHzejFDcUCuXGY/GR4Dzg7v carson@air"
    ];
  };
}
