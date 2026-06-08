{config, ...}: {
  networking = {
    # Keep DHCP ownership explicit: only networkd should request IPv4 DHCP.
    useDHCP = false;
    dhcpcd.enable = false;
    # Allow HTTP, HTTPS, SSH connections
    firewall = {
      enable = true;
      allowedTCPPorts = [80 443 22];
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Use networkd to set static ipv6, DHCP for ipv4
  systemd.network.enable = true;
  systemd.network.networks."30-enp1s0" = {
    matchConfig.Name = "enp1s0";
    networkConfig.DHCP = "ipv4";
    address = ["2a01:4ff:1f0:b3c5::1/64"];
    routes = [{Gateway = "fe80::1";}];
  };

  services.tailscale = {
    enable = true;
    interfaceName = "ts0";
  };
}
