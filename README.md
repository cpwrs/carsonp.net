# carsonp.net

NixOS configuration for my web apps running on a Hetzner CPX21 VPS.

### Reverse proxy

All apps are accessible under the `carsonp.net` domain behind an Nginx reverse proxy:
- `carsonp.net` -> My [blog](https://github.com/cpwrs/blog) on `[::1]:8000`
- `vault.carsonp.net` -> [vaultwarden](https://github.com/dani-garcia/vaultwarden) on `[::1]:8001`
- `rss.carsonp.net` -> [miniflux](https://miniflux.app) on `[::1]:8002`
- `*.carsonp.net` -> returns 404

### TLS Certification

I'm using the [lego](https://go-acme.github.io) ACME client to renew TLS certificates from Let's Encrypt.
Certificates are issued for `carsonp.net` and `*.carsonp.net` using the DNS-01 challenge.
This requires a HETZNER_API_TOKEN to temporarily write a TXT record to my Hetzner DNS zone.
`acme-order-renew-carsonp.net.service` triggers renewal of certs.
