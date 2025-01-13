# carsonp.net

Full stack of my personal website.

## Deploy

The backend is a FastAPI python app sitting behind a nginx reverse proxy.
The nix flake provides a development shell, the packaged python code, and a NixOS config for an amazon EC2 instance.
For slow instances, build and deploy the OS locally using:
```bash
nixos-rebuild --target-host root@instance-ip --flake .#server switch
```
The NixOS config sets up nginx, grabs Let's Encrypt certificates, opens TCP ports, and defines a systemd service to start the web app. All it depends on imperatively is a web-app.env on the server for any secrets the API uses.
