# carsonp.net

Full stack personal website.

## Deploy

### Production
For slow instances, build the OS locally and deploy to EC2: 
```bash
nixos-rebuild --target-host root@instance-ip --flake .#server switch
```
This NixOS config sets up nginx, grabs Let's Encrypt certificates, opens TCP ports, and defines a systemd service to start the web app.

### Development
Enter the dev environment with `nix develop`.
Age recipients defined in `secrets.nix` can decrypt the secret environment variables:
```bash
age --decrypt -i ~/.ssh/id_ed25519 -o .env secrets/env.age
source .env
```
Then, start the server with an optional host and port argument:
```bash
python3 app/backend.py --host 127.0.0.1 --port 8000
```
