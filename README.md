# carsonp.net
Enter the dev environment with `nix develop`.
Start the server locally with an optional host and port argument:
```bash
python3 app/backend.py --host 127.0.0.1 --port 8000
```

### Deploy
Age recipients defined in `secrets.nix` have deploy privileges and can decrypt the prod environment secrets.
Build the OS locally and deploy to the instance:
```nix
nix run .#deploy
```
This NixOS config sets up nginx, grabs Let's Encrypt certificates, opens TCP ports, and defines a systemd service to start the web app.
