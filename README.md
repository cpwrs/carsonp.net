# carsonp.net

NixOS configuration for my web apps running on a Hetzner CPX21 VPS.

All apps are accessible under the `carsonp.net` domain behind an Nginx reverse proxy:
- `carsonp.net` -> My [blog](https://github.com/cpwrs/blog)!
- `vault.carsonp.net` -> [vaultwarden](https://github.com/dani-garcia/vaultwarden)
- `rss.carsonp.net` -> [miniflux](https://miniflux.app)

I'm using the [lego](https://go-acme.github.io) ACME client to renew TLS certificates from Let's Encrypt.
Certificates are issued for `carsonp.net` and `*.carsonp.net` using the DNS-01 challenge and Route53 provider.
