let
  systems = {
    server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKqjJ/hkr0Z5SI8AXXA1qzCI8E40gbV79tsJLjr/tcua";
    local = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLFlimfo5Wwn7aL4MjHAkQ8FRB3ifif6oa7HqYGt852";
  };
in {
  "env.age".publicKeys = builtins.attrValues systems;
}
