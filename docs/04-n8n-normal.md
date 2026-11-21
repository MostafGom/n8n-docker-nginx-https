# Step 5a: n8n in normal mode

One n8n instance does everything: the editor, triggers, webhooks and running workflows. This is the right choice for learning n8n and for light use.

What starts:

| Service | Job |
|---|---|
| `n8n` | n8n itself |
| `postgres` | Database for workflows, credentials and execution history |
| `n8n-runners` | Task runner: runs the code of Code nodes, separately from n8n |

nginx must already be running ([step 4](03-start-nginx.md)).

## 1. Create your settings file

From the `docker-projects` folder:

| macOS / Linux | Windows (PowerShell) |
|---|---|
| `cd n8n` | `cd n8n` |
| `./generate-env.sh` | `.\generate-env.ps1` |

This copies `.env.example` to `.env` and fills in random passwords and keys. The `.env` file is ignored by git.

> **Back up `.env`.** It holds `N8N_ENCRYPTION_KEY`, which n8n uses to encrypt the credentials you save. If you lose it or change it, those credentials can no longer be read.

Optional: open `.env` and set `GENERIC_TIMEZONE` to your timezone (for example `Europe/Berlin`), so schedule triggers fire at your local time.

## 2. Start n8n

Still inside the `n8n` folder:

```
docker compose up -d
```

The first start downloads the images and can take a few minutes.

## 3. Check

```
docker compose ps
```

Look at the `SERVICE` and `STATUS` columns: `n8n` and `postgres` should show `healthy`, and `n8n-runners` should show `Up`.

Open <https://n8n.apps.mylocalhost>. n8n asks you to create the owner account. That account is stored only in your local database.

## Useful commands

Run these inside the `n8n` folder.

| What | Command |
|---|---|
| See the logs | `docker compose logs -f n8n` |
| Stop (data is kept) | `docker compose down` |
| Start again | `docker compose up -d` |
| **Delete everything**, including workflows and credentials | `docker compose down -v` |

## Updating n8n

1. Pick a version from the [n8n releases](https://github.com/n8n-io/n8n/releases). Read the release notes for breaking changes.
2. Open `.env` and change `N8N_VERSION`. n8n and the task runner use the same value, as n8n requires.
3. Apply it:

   ```
   docker compose pull
   docker compose up -d
   ```

## Next

- [n8n in queue mode](05-n8n-queue-mode.md)
- [Add another app behind the same proxy](06-add-another-app.md)
