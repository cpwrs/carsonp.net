{
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  system.stateVersion = "26.05";

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"
    "sd_mod"
  ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  users.users.root.hashedPassword = "!";
  security.sudo.wheelNeedsPassword = false;

  nix = {
    channel.enable = false;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [
        "root"
        "@wheel"
      ];

      extra-substituters = [
        "https://cache.nixos.org"
      ];

      http-connections = 50;
      warn-dirty = false;
    };

    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    optimise = {
      automatic = true;
      dates = ["04:00"];
    };
  };

  environment.systemPackages = [pkgs.nh];
}
