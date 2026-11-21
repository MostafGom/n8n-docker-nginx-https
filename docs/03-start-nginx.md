# Step 4: start nginx

The commands are the same on Windows, macOS and Linux. Start in the `docker-projects` folder.

## 1. Create the shared network (once)

nginx and every app join this Docker network. It is how nginx reaches the apps.

```
docker network create local-shared
```

If it says the network already exists, that is fine.

## 2. Start nginx

```
cd nginx
docker compose up -d
cd ..
```

## 3. Check

```
docker compose -f nginx/docker-compose.yml ps
```

The `nginx` service should show `Up`.

Now open <https://n8n.apps.mylocalhost> in your browser. You should see:

- a **padlock** with no certificate warning, and
- a **502 Bad Gateway** page.

The 502 is expected: nginx is working, and n8n is not started yet. If you get a certificate warning or the page does not load at all, see [troubleshooting](troubleshooting.md).

## Useful commands

Run these inside the `nginx` folder.

| What | Command |
|---|---|
| Apply changes after editing a file in `conf.d/` | `docker compose exec nginx nginx -s reload` |
| Test the config for mistakes | `docker compose exec nginx nginx -t` |
| See the logs | `docker compose logs -f nginx` |
| Stop nginx | `docker compose down` |

nginx starts again by itself when Docker starts, until you stop it with `docker compose down`.

## Next

- [Step 5a: n8n in normal mode](04-n8n-normal.md)
- [Step 5b: n8n in queue mode](05-n8n-queue-mode.md)
