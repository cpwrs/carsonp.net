# carsonp.net

NixOS configuration for my web apps running on a Hetzner CPX21 VPS.

All apps are accessible under the `carsonp.net` domain behind an Nginx reverse proxy:
- `carsonp.net` -> My [blog](https://github.com/cpwrs/blog) on `[::1]:8000`
- `vault.carsonp.net` -> [vaultwarden](https://github.com/dani-garcia/vaultwarden) on `[::1]:8001`
- `rss.carsonp.net` -> [miniflux](https://miniflux.app) on `[::1]:8002`

I'm using the [lego](https://go-acme.github.io) ACME client to renew TLS certificates from Let's Encrypt.
Certificates are issued for `carsonp.net` and `*.carsonp.net` using the DNS-01 challenge and Hetzner DNS zone provider.

The `acme-order-renew-carsonp.net` systemd service triggers renewal of ACME certifications.
