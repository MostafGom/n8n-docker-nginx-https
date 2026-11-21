# Setup prompt: let an AI assistant do the setup

If you use an AI coding assistant that can run commands on your computer (Claude Code, Cursor, Codex CLI, Gemini CLI and similar), you can paste the prompt below and it will walk through the whole setup for you.

How to use it:

1. Open your assistant in a terminal, in the folder where you want `docker-projects` to live (for example your home folder). On Windows, start it from PowerShell, not from WSL.
2. Copy everything inside the box below and paste it as your message.
3. Answer its questions. It will ask before anything that needs your password or administrator rights.

A chat-only assistant (one that cannot run commands) can still use this prompt: it will give you the commands one at a time to run yourself.

```text
Set up n8n on this computer with local HTTPS, using this repository:
https://github.com/MostafGom/n8n-docker-nginx-https.git

The repository contains an nginx reverse proxy plus two n8n setups (normal mode and
queue mode). Its README.md and the numbered guides in docs/ are the source of truth.
Read them and follow them exactly. Do not invent your own configuration and do not
edit the repository's compose or nginx files.

Before you start, ask me one question: do I want n8n in normal mode, queue mode, or
both? If I am not sure, use normal mode.

Then work through these steps in order. After each step, tell me in one line what
you did and whether it worked.

1. Detect my operating system (Windows, macOS, or Linux and which distribution).
   On Windows, use the .ps1 scripts with Windows PowerShell, never the .sh scripts
   and never WSL or Git Bash. Run each .ps1 script like this, so it works even when
   every command starts a fresh shell:
     powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check-prereqs.ps1

2. Get the repository. If the current folder is already this repository, use it.
   Otherwise check that Git is installed ("git --version"; if it is missing, help me
   install it first), then clone the repository into a folder named
   "docker-projects" and work from there.

3. Run the check script to see what is missing:
   - macOS / Linux: ./scripts/check-prereqs.sh
   - Windows: scripts\check-prereqs.ps1 (run as shown in step 1)

4. Install anything it reports as missing (Docker, mkcert) by following
   docs/01-install-docker-<my system>.md. Show me the commands and wait for my OK
   before installing anything. If a step needs a graphical installer, a restart, or
   signing out and in again, tell me exactly what to do and wait until I say it is done.

5. Create the certificate and add the hosts-file lines, following
   docs/02-https-and-hosts.md. Only add hosts lines that are not already there.
   Both parts need my password or administrator rights: the certificate script runs
   "mkcert -install" (asks for a password on macOS/Linux, shows a security prompt on
   Windows) and the hosts file can only be edited as administrator. Do not run these
   yourself if you cannot show me a password prompt. Instead give me the exact
   command, tell me which window to run it in (on Windows the hosts command needs a
   PowerShell opened as administrator), and wait until I say it is done.

6. Create the Docker network and start nginx, following docs/03-start-nginx.md.

7. Start the n8n setup(s) I chose, following docs/04-n8n-normal.md and/or
   docs/05-n8n-queue-mode.md. Create the .env file with the generate-env script
   from that folder.

8. Verify: run the check script again, run "docker compose ps" in each folder you
   started and wait until the services are healthy, then request
   https://<address>/healthz and confirm it answers with status 200 and no
   certificate error. On macOS / Linux use:
     curl -sS -o /dev/null -w "%{http_code}" --cacert "$(mkcert -CAROOT)/rootCA.pem" https://<address>/healthz
   On Windows use curl.exe (not curl, which is a different command in PowerShell):
     curl.exe -sS -o NUL -w "%{http_code}" https://<address>/healthz

9. Finish with a short summary: the address(es) to open in my browser, the location
   of each .env file with a reminder to back it up, and the commands to stop and
   start everything. Remind me to restart my browser before opening the address.

Rules:
- Ask before any command that needs sudo or administrator rights, and say what it
  does. If you cannot run it yourself, give me the exact command to run and wait.
- If port 80 or 443 is already in use, tell me which program is using it and ask me
  what to do. Never stop or remove programs or containers that are not part of this
  repository on your own.
- Never overwrite or delete an existing .env file, and never run
  "docker compose down -v" or delete Docker volumes. Those destroy saved data.
- Never print the contents of .env files or of the mkcert CA folder.
- If something fails, check docs/troubleshooting.md first. If the fix is not there,
  stop and show me the exact error instead of guessing.
```

Prefer to do it by hand? Follow the [quick start in the README](README.md#quick-start).
