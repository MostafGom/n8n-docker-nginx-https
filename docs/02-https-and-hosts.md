# Step 3: certificate and hosts file

Run everything from the `docker-projects` folder.

## 1. Create the certificate

| macOS / Linux | Windows (PowerShell) |
|---|---|
| `./nginx/generate-certs.sh` | `.\nginx\generate-certs.ps1` |

The script does two things:

1. `mkcert -install` creates a private certificate authority on your machine and tells your system and browsers to trust it. It may ask for your password (macOS/Linux) or show a security prompt (Windows: choose **Yes**).
2. It creates one certificate for `*.apps.mylocalhost` in `nginx/certs/`. Because it is a wildcard, the same certificate covers every app you add later.

**Restart your browser** afterwards so it picks up the new certificate authority.

> The certificate authority's private key lives in the folder shown by `mkcert -CAROOT`. Never share that folder. The `nginx/certs/` folder is ignored by git for the same reason.

**Firefox on Windows:** mkcert cannot add its authority to Firefox on Windows. If Firefox shows a warning, open `about:config`, set `security.enterprise_roots.enabled` to `true`, and restart Firefox.

## 2. Add the addresses to your hosts file

`apps.mylocalhost` is not a real internet domain. The hosts file tells your computer that these names mean "this machine".

The lines to add:

```text
127.0.0.1 n8n.apps.mylocalhost
127.0.0.1 n8n-queue.apps.mylocalhost
```

**macOS / Linux** (asks for your password):

```bash
printf '\n127.0.0.1 n8n.apps.mylocalhost\n127.0.0.1 n8n-queue.apps.mylocalhost\n' | sudo tee -a /etc/hosts
```

**Windows:** open PowerShell **as administrator** and run:

```powershell
Add-Content -Path "$env:SystemRoot\System32\drivers\etc\hosts" -Value "`n127.0.0.1 n8n.apps.mylocalhost`n127.0.0.1 n8n-queue.apps.mylocalhost"
```

Or edit the file by hand: start Notepad as administrator and open `C:\Windows\System32\drivers\etc\hosts`.

Then close the administrator window and go back to your normal PowerShell window in the `docker-projects` folder. All the remaining steps run there.

Run each command only once. Running it again adds duplicate lines (harmless, but untidy).

## 3. Check

| macOS / Linux | Windows (PowerShell) |
|---|---|
| `./scripts/check-prereqs.sh` | `.\scripts\check-prereqs.ps1` |

The certificate line and both hosts lines should now show `[ OK ]`.

## Next

[Step 4: start nginx](03-start-nginx.md)
