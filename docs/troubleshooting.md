# Troubleshooting

Start with the check script. It finds most problems:

| macOS / Linux | Windows (PowerShell) |
|---|---|
| `./scripts/check-prereqs.sh` | `.\scripts\check-prereqs.ps1` |

## The browser shows a certificate warning

- Restart the browser completely. Browsers read the list of trusted authorities at startup.
- Run the certificate script again ([step 3](02-https-and-hosts.md)). It is safe to repeat. If nginx is already running, make it load the new certificate: `docker compose exec nginx nginx -s reload` inside the `nginx` folder.
- The certificate is valid for a little over two years. When it expires, do the same: run the script again and reload nginx.
- **Linux:** the `certutil` tools must be installed before `mkcert -install` runs ([Linux guide](01-install-docker-linux.md#3-mkcert)). Install them and run the script again.
- **Windows:** mkcert must have been run in PowerShell, not inside WSL. For Firefox, see the note in [step 3](02-https-and-hosts.md#1-create-the-certificate).
- The address must be exactly one level below `apps.mylocalhost`.

## The page does not load at all ("site can't be reached")

- Check the hosts file lines ([step 3](02-https-and-hosts.md#2-add-the-addresses-to-your-hosts-file)).
- Type the full address including `https://`. Without it, some browsers search the web for the name instead.
- Check that nginx is running: `docker compose ps` inside the `nginx` folder.
- If you use a VPN or a custom DNS tool, it may bypass the hosts file. Turn it off to test.

## nginx will not start: port 80 or 443 is already in use

Another program is using the port. Find it:

- **Linux:** `sudo ss -ltnp | grep -E ':(80|443)\s'`
- **macOS:** `sudo lsof -nP -iTCP:80 -iTCP:443 -sTCP:LISTEN`
- **Windows (PowerShell):** `Get-NetTCPConnection -LocalPort 80,443 -State Listen | Select-Object LocalPort,OwningProcess`, then look up the `OwningProcess` number in Task Manager → Details (PID column). Number 4 ("System") usually means the Windows web server, IIS.

Common causes are another web server (Apache, nginx, IIS) or another reverse proxy container (check `docker ps`). Stop it, then start nginx again.

## 502 Bad Gateway

nginx is running but cannot reach the app.

- The app is stopped or still starting. Run `docker compose ps` in the app's folder and wait for `healthy`.
- The app did not join the network: its compose file must list `local-shared` for the web service.
- The name or port after `set $upstream` in the app's `nginx/conf.d/*.conf` file does not match the service name and the port the app listens on.

## 404 "no app is configured for ..."

nginx has no site file for that address. Check that the file in `nginx/conf.d/` ends in `.conf`, that `server_name` matches the address exactly, and that you reloaded nginx.

## "network local-shared declared as external, but could not be found"

Create it: `docker network create local-shared`

## n8n: "variable is not set" warnings or the containers will not start

The `.env` file is missing. Run the `generate-env` script in that folder ([normal](04-n8n-normal.md), [queue](05-n8n-queue-mode.md)).

## n8n: the editor says "Connection lost"

The editor's live connection goes through a WebSocket. This repo's nginx files already handle it. If you wrote your own site file, start again from `nginx/templates/app.conf.example` and keep the `Upgrade` and `Connection` lines.

## n8n: credentials cannot be decrypted

`N8N_ENCRYPTION_KEY` in `.env` is different from the one used when the credentials were saved. Restore the original `.env`. If it is lost, the saved credentials cannot be recovered and must be entered again.

## n8n: Code nodes fail or time out

Check that the task runner is up and its version matches n8n: `docker compose ps` should show the `-runners` containers as `Up`, and both images come from the single `N8N_VERSION` in `.env`. Look at `docker compose logs` for the runner container.

## A webhook from an outside service never arrives

That is expected. `apps.mylocalhost` exists only on your computer, so nothing on the internet can call it. Webhooks you call from your own machine work.

## Windows: scripts cannot be loaded because running scripts is disabled

Run this in the same PowerShell window, then run the script again:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## Windows: I ran the `.sh` scripts in WSL or Git Bash and the browser still warns

The `.sh` scripts are for macOS and Linux. Run inside WSL, they install the certificate authority and check the hosts file of the Linux system, not of Windows, so your Windows browser never learns about them. Use the `.ps1` scripts in PowerShell instead.

## Start over completely

This deletes all n8n data. Run it inside the `n8n` or `n8n-queue` folder:

```
docker compose --profile extra-workers down -v
```

Then delete that folder's `.env` and follow the guide again from the `generate-env` step.
