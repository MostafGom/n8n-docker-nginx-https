# Step 1 (macOS): install Docker and mkcert

> **Note:** the macOS steps in this repo follow the official Docker and mkcert documentation, but they have not been tested on a real Mac yet. If a step behaves differently for you, search online for the exact error message or ask an AI assistant to help with your specific case.

## 1. Docker Desktop

Docker Desktop supports the current macOS release and the two before it, on both Apple silicon and Intel Macs ([official install page](https://docs.docker.com/desktop/setup/install/mac-install/)).

1. Download **Docker Desktop for Mac** from the [official install page](https://docs.docker.com/desktop/setup/install/mac-install/). Pick the download for your chip (Apple menu → About This Mac shows which one you have).
2. Open `Docker.dmg` and drag Docker to **Applications**.
3. Start **Docker** from Applications and accept the agreement. Wait until Docker Desktop shows that the engine is running.
4. Open Terminal and check:

   ```bash
   docker --version
   docker compose version
   docker run --rm hello-world
   ```

   The last command should print "Hello from Docker!".

## 2. mkcert

These commands need [Homebrew](https://brew.sh). They are the ones from the [mkcert README](https://github.com/FiloSottile/mkcert#macos):

```bash
brew install mkcert
```

If you use Firefox, also run:

```bash
brew install nss
```

Check:

```bash
mkcert -version
```

## 3. Git

Run `git --version`. If Git is missing, macOS offers to install the command line tools; accept.

## Next

Go back to the [README](../README.md#quick-start) and continue with step 2 (clone the repo).
