# Step 5b: n8n in queue mode

In queue mode the work is split up:

- The **main** instance serves the editor and receives triggers and webhooks. It does not run workflows. It puts each execution on a queue.
- **Redis** holds that queue.
- **Workers** take executions from the queue and run them. More workers means more workflows running at the same time.

This is how n8n is scaled in production ([official queue mode docs](https://docs.n8n.io/hosting/scaling/queue-mode/)). Locally it is useful for learning that setup and for testing workflows the way they will run on a server.

What starts:

| Service | Job |
|---|---|
| `n8n-queue-main` | Editor, triggers, webhooks |
| `n8n-queue-worker-1` | Runs the workflows |
| `n8n-queue-main-runners`, `n8n-queue-worker-1-runners` | Task runners: run the code of Code nodes. Each n8n container has its own. |
| `redis` | The queue |
| `postgres` | Database |

That is six containers, so it needs noticeably more memory than normal mode.

This setup is separate from the normal-mode n8n in the `n8n/` folder. It has its own address, database and encryption key, and both can run at the same time.

nginx must already be running ([step 4](03-start-nginx.md)).

## 1. Create your settings file

From the `docker-projects` folder:

| macOS / Linux | Windows (PowerShell) |
|---|---|
| `cd n8n-queue` | `cd n8n-queue` |
| `./generate-env.sh` | `.\generate-env.ps1` |

> **Back up `.env`.** It holds `N8N_ENCRYPTION_KEY`. The main instance and every worker must use the same key, and if you lose it your saved credentials can no longer be read.

Optional settings in `.env`:

- `GENERIC_TIMEZONE`: your timezone, for example `Europe/Berlin`
- `N8N_WORKER_CONCURRENCY`: how many executions one worker runs at the same time (default 10)

## 2. Start n8n

Still inside the `n8n-queue` folder:

```
docker compose up -d
```

## 3. Check

```
docker compose ps
```

Look at the `SERVICE` and `STATUS` columns: `n8n-queue-main`, `n8n-queue-worker-1`, `postgres` and `redis` should show `healthy`. The two `-runners` containers should show `Up`.

Open <https://n8n-queue.apps.mylocalhost> and create the owner account.

## See the queue working

1. In the editor, create a workflow with a **Manual Trigger** connected to any node, and click **Execute workflow**.
2. Look at the worker's log:

   ```
   docker compose logs n8n-queue-worker-1
   ```

   You will see a line like `Worker finished execution 1 (job 1)`. The main instance's log shows `Enqueued execution 1 (job 1)`: main queued the job and the worker ran it.

## Add a second worker

A second worker and its task runner are already defined, switched off by default. Start them with:

```
docker compose --profile extra-workers up -d
```

Executions are now shared between `n8n-queue-worker-1` and `n8n-queue-worker-2`.

Once you have used the profile, add `--profile extra-workers` to your other commands too (`ps`, `logs`, `down`), so they include the second worker.

For a third worker, copy the `n8n-queue-worker-2` and `n8n-queue-worker-2-runners` blocks in `docker-compose.yml` and replace `worker-2` with `worker-3` everywhere in the copy. Leave the `profiles: ["extra-workers"]` lines as they are, so the same commands cover every extra worker. Each worker needs its own task runner, pointing at that worker.

## Useful commands

Run these inside the `n8n-queue` folder.

| What | Command |
|---|---|
| See all logs | `docker compose logs -f` |
| Stop (data is kept) | `docker compose --profile extra-workers down` |
| Start again | `docker compose up -d` |
| **Delete everything**, including workflows and credentials | `docker compose --profile extra-workers down -v` |

To update n8n, follow [Updating n8n](04-n8n-normal.md#updating-n8n) in this folder. The one `N8N_VERSION` value updates main, the workers and the task runners together.

## Next

[Add another app behind the same proxy](06-add-another-app.md)
