# n8n on your own machine, with real HTTPS

Run [n8n](https://n8n.io) locally with Docker, behind an nginx reverse proxy, on trusted HTTPS addresses:

| Folder | What it is | Address |
|---|---|---|
| `nginx/` | Reverse proxy. Handles HTTPS for every app. | (no page of its own) |
| `n8n/` | n8n in normal mode (one n8n + PostgreSQL) | https://n8n.apps.mylocalhost |
| `n8n-queue/` | n8n in queue mode (main + workers + Redis + PostgreSQL) | https://n8n-queue.apps.mylocalhost |

You can run either n8n, or both at the same time. Each keeps its own data.

The same proxy can serve any other Docker app you add later: one small config file per app, no new certificate. That is why the guide has you clone this repo into a folder called `docker-projects`.

> Everything here is for **local use on your own computer**. The addresses only work on your machine, and services on the internet cannot reach them (so webhooks sent by outside services will not arrive).

## How it fits together

```
 Browser ── https://n8n.apps.mylocalhost ────────┐
 Browser ── https://n8n-queue.apps.mylocalhost ──┤
                                                 ▼
                              nginx  (ports 80 + 443, HTTPS certificate)
                                                 │   Docker network "local-shared"
                         ┌───────────────────────┴───────────────┐
                         ▼                                       ▼
                  n8n  (normal)                         n8n-queue-main
                  + postgres                            + workers + redis + postgres
                  + task runner                         + task runners
```

- **mkcert** creates a certificate your browser trusts, so you get a padlock with no warnings.
- The **hosts file** tells your computer that the `*.apps.mylocalhost` names point to itself.
- Only nginx publishes ports, and only on `127.0.0.1`, so nothing is reachable from other devices on your network. The apps are reachable only through nginx.

## Quick start

> **Using an AI coding assistant?** Paste the prompt from [SETUP-PROMPT.md](SETUP-PROMPT.md) and it will do the steps below for you.

Do the steps in order. Each one links to a short guide.

1. **Install Docker and mkcert** for your system:
   [Windows](docs/01-install-docker-windows.md) · [macOS](docs/01-install-docker-macos.md) · [Linux](docs/01-install-docker-linux.md)

2. **Get this repo** into a folder named `docker-projects` and go into it:

   ```
   git clone https://github.com/MostafGom/n8n-docker-nginx-https.git docker-projects
   cd docker-projects
   ```

3. **[Create the certificate and add the addresses to your hosts file](docs/02-https-and-hosts.md)**

4. **[Start nginx](docs/03-start-nginx.md)**

5. Start n8n. Pick one, or do both:
   - **[Normal mode](docs/04-n8n-normal.md)**: start here if you are new to n8n
   - **[Queue mode](docs/05-n8n-queue-mode.md)**: the scalable setup with workers

At any point, run the check script. It changes nothing and tells you what is done and what is left:

| macOS / Linux | Windows (PowerShell) |
|---|---|
| `./scripts/check-prereqs.sh` | `.\scripts\check-prereqs.ps1` |

Later: **[add another app behind the same proxy](docs/06-add-another-app.md)** · **[troubleshooting](docs/troubleshooting.md)**

## What was tested

- **Linux (Fedora, Docker Engine 29, Compose v5):** both n8n modes running together behind nginx on ports 80 and 443, workflows executed in each, the editor's WebSocket connection, and a second worker.
- **Windows and macOS:** the guides and PowerShell scripts follow the official Docker and mkcert instructions. The PowerShell scripts were run with PowerShell 7 on Linux, but not on a Windows machine. If something differs on your system, search online for the exact error message or ask an AI assistant to help with your specific case.

Versions are pinned: n8n 2.48.7, PostgreSQL 17.12, Redis 8.8.4, nginx 1.30.7. To change the n8n version, see [Updating n8n](docs/04-n8n-normal.md#updating-n8n).

## Where the settings come from

The n8n settings follow the official documentation:
[Docker installation](https://docs.n8n.io/hosting/installation/docker/) ·
[reverse proxy / webhook URL](https://docs.n8n.io/hosting/configuration/configuration-examples/webhook-url/) ·
[queue mode](https://docs.n8n.io/hosting/scaling/queue-mode/) ·
[task runners](https://docs.n8n.io/hosting/configuration/task-runners/) ·
[supported databases](https://docs.n8n.io/hosting/configuration/supported-databases-settings/) ·
[official Compose examples](https://github.com/n8n-io/n8n-hosting)

## AI assistance

Parts of this repository (configuration, scripts and documentation) were generated with the help of an AI assistant, then reviewed and tested by the author. See [What was tested](#what-was-tested) for what has been run on a real machine.

## License

[MIT](LICENSE)
