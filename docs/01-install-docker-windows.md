# Step 1 (Windows): install Docker and mkcert

> **Note:** the Windows steps and the `.ps1` scripts in this repo follow the official Docker and mkcert documentation, but they have not been tested on a real Windows machine yet. If a step behaves differently for you, search online for the exact error message or ask an AI assistant to help with your specific case.

Run every command in this guide in **PowerShell**, not inside WSL. mkcert has to run on Windows itself so that your Windows browsers trust the certificate.

## 1. Docker Desktop

You need a 64-bit Windows 10 (22H2) or Windows 11 (23H2 or newer) with 8 GB RAM and hardware virtualization enabled in the BIOS/UEFI. The exact list of supported versions and editions is on [Docker's Windows install page](https://docs.docker.com/desktop/setup/install/windows-install/).

1. Docker Desktop uses WSL 2. Check whether you already have it:

   ```powershell
   wsl --version
   ```

   If that prints version numbers, go to the next step. If not, open PowerShell **as administrator** and run:

   ```powershell
   wsl --install
   ```

   Restart the computer if it asks you to, then run this in an administrator PowerShell:

   ```powershell
   wsl --update
   ```

2. Download **Docker Desktop for Windows** from the [official install page](https://docs.docker.com/desktop/setup/install/windows-install/) and run `Docker Desktop Installer.exe`. Keep **Use WSL 2 instead of Hyper-V** selected.

3. Start **Docker Desktop** from the Start menu (it does not start by itself after installing) and accept the agreement. Wait until it shows that the engine is running.

4. Open a **new** PowerShell window and check:

   ```powershell
   docker --version
   docker compose version
   docker run --rm hello-world
   ```

   The last command should print "Hello from Docker!".

## 2. Git

If `git --version` does not work, install Git from <https://git-scm.com/download/win> and open a new PowerShell window.

## 3. mkcert

Use whichever of these you have. The first works on a standard Windows 10/11:

```powershell
winget install FiloSottile.mkcert
```

or, as documented in the [mkcert README](https://github.com/FiloSottile/mkcert#windows):

```powershell
choco install mkcert
```

```powershell
scoop bucket add extras
scoop install mkcert
```

Open a **new** PowerShell window, then check:

```powershell
mkcert -version
```

## 4. Allow this repo's scripts to run

Windows blocks PowerShell scripts by default. In each new PowerShell window where you want to run the scripts from this repo, run this first. It only affects that one window:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## Next

Go back to the [README](../README.md#quick-start) and continue with step 2 (clone the repo). Clone it somewhere on your Windows drive, for example `C:\Users\<you>\docker-projects`.
