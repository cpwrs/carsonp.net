let
  recipients = {
    server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKqjJ/hkr0Z5SI8AXXA1qzCI8E40gbV79tsJLjr/tcua";
    ci = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLFlimfo5Wwn7aL4MjHAkQ8FRB3ifif6oa7HqYGt852";
  };
in {
  # Secret environment variables for production boxes
  # CI boxes needs access to rotate keys
  "secrets/prodenv.age".publicKeys = builtins.attrValues recipients;

  # Deployment secrets for CI
  "secrets/pem.age".publicKeys = [ recipients.ci ];
  "secrets/ip.age".publicKeys = [ recipients.ci ];
}
