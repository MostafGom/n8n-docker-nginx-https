# Add another app behind the same proxy

The proxy is not tied to n8n. Any app that runs in Docker can get its own `https://<name>.apps.mylocalhost` address in three steps. You do not need a new certificate: the existing one covers every name that ends in `.apps.mylocalhost`.

This guide adds a tiny demo app called `whoami`. Replace the name, image and port with those of your own app.

## 1. Give the app a folder and join the shared network

Create `docker-projects/whoami/docker-compose.yml`:

```yaml
name: whoami

services:
  whoami:
    image: traefik/whoami:v1.11.0
    restart: unless-stopped
    networks:
      - local-shared

networks:
  local-shared:
    external: true
```

Two things matter here:

- The service joins `local-shared`, the network nginx is on.
- There is **no `ports:` section**. nginx reaches the app inside the network, so nothing else needs to be published.

If your app has a database or other helpers, leave them off `local-shared`. List both `default` and `local-shared` under the web service's `networks:`, as `n8n/docker-compose.yml` does, and give the helpers no `networks:` entry at all.

Start it:

```
cd whoami
docker compose up -d
cd ..
```

## 2. Add a site file to nginx

Copy the template:

| macOS / Linux | Windows (PowerShell) |
|---|---|
| `cp nginx/templates/app.conf.example nginx/conf.d/whoami.conf` | `Copy-Item nginx\templates\app.conf.example nginx\conf.d\whoami.conf` |

Open `nginx/conf.d/whoami.conf` and change the two lines marked `CHANGE ME`:

```nginx
    server_name whoami.apps.mylocalhost;
```

```nginx
        set $upstream http://whoami:80;
```

The upstream is `<service name from the compose file>:<port the app listens on inside its container>`. For `whoami` that port is 80.

Reload nginx:

```
cd nginx
docker compose exec nginx nginx -t
docker compose exec nginx nginx -s reload
cd ..
```

## 3. Add the address to your hosts file

**macOS / Linux:**

```bash
printf '\n127.0.0.1 whoami.apps.mylocalhost\n' | sudo tee -a /etc/hosts
```

**Windows** (PowerShell as administrator):

```powershell
Add-Content -Path "$env:SystemRoot\System32\drivers\etc\hosts" -Value "`n127.0.0.1 whoami.apps.mylocalhost"
```

Open <https://whoami.apps.mylocalhost>. You get a padlock and a plain-text page describing the request.

## Rules to remember

- Names must be exactly one level below `apps.mylocalhost`: `whoami.apps.mylocalhost` works, `a.b.apps.mylocalhost` is not covered by the certificate.
- Service names on `local-shared` must be unique across all your projects, because nginx finds apps by that name.
- Never put a database or cache on `local-shared`. The n8n containers are on that network too and look up their own `postgres` and `redis` by name; a second service with one of those names on the shared network would confuse them.
- Git will list your new folder and site file as untracked. That is expected; they are yours.
- To take an app offline without deleting its config, rename its file so it no longer ends in `.conf` (for example `whoami.conf.off`) and reload nginx.
