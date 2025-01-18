# carsonp.net

Full stack personal website.

## Deploy

Production: For slow instances, build the OS locally and deploy to EC2: 
```bash
nixos-rebuild --target-host root@instance-ip --flake .#server switch
```
This NixOS config sets up nginx, grabs Let's Encrypt certificates, opens TCP ports, and defines a systemd service to start the web app. All it depends on imperatively is a web-app.env on the server for any secrets the API uses.

Development:
Enter the `devShell` provided in the nix flake, then deploy locally:
```bash
cd app/
uvicorn backend:app --host 127.0.0.1 --port 8000
```
