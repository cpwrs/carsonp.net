let
  recipients = {
    server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1MhrVptKj83FK6cCuRWze3yILDnyCFhIJKWeFCBgFQ"; # root@server
    toaster = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID9+4cvvVu5SOVi1/rxU6xhUcBAhW9frDaE0TI5MXrIX"; # carson@toaster
  };
in {
  "secrets/env.age".publicKeys = builtins.attrValues recipients;

  # Only dev machines need ip/pem to deploy.
  "secrets/pem.age".publicKeys = [ recipients.toaster ];
  "secrets/ip.age".publicKeys = [ recipients.toaster ];
}
