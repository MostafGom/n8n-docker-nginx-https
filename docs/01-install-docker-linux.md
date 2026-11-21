# Step 1 (Linux): install Docker and mkcert

## 1. Docker Engine

If `docker --version` and `docker compose version` already work, skip to [Run Docker without sudo](#2-run-docker-without-sudo).

The commands below are the ones from Docker's own install pages. If your distribution is not listed, find it at <https://docs.docker.com/engine/install/>.

### Ubuntu

From <https://docs.docker.com/engine/install/ubuntu/>. The first block adds Docker's signing key, the second adds Docker's package repository and installs Docker:

```bash
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

```bash
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Debian

Follow <https://docs.docker.com/engine/install/debian/>. The steps are the same as for Ubuntu, with Debian's download URLs.

### Fedora

From <https://docs.docker.com/engine/install/fedora/>:

```bash
sudo dnf config-manager addrepo --from-repofile https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
```

## 2. Run Docker without sudo

From <https://docs.docker.com/engine/install/linux-postinstall/>:

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```

`groupadd` may say the group already exists; that is fine. `newgrp` applies the change to the current terminal only. Log out and back in to apply it everywhere. Note that members of the `docker` group effectively have root access to the machine.

Check:

```bash
docker --version
docker compose version
docker run --rm hello-world
```

The last command should print "Hello from Docker!".

## 3. mkcert

Install the certificate tools **together with** mkcert, before the first `mkcert -install`. Without them, Chrome and Firefox will not trust the certificate.

**Ubuntu** (22.04 or newer):

```bash
sudo apt install libnss3-tools mkcert
```

**Fedora:**

```bash
sudo dnf install nss-tools mkcert
```

**Arch:**

```bash
sudo pacman -S nss mkcert
```

**Anything else:** install your distribution's `certutil` package (`libnss3-tools` on Debian, `mozilla-nss-tools` on openSUSE), then the prebuilt binary as described in the [mkcert README](https://github.com/FiloSottile/mkcert#linux):

```bash
curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
chmod +x mkcert-v*-linux-amd64
sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert
```

On an ARM machine, replace `amd64` with `arm64` in all three lines.

Check:

```bash
mkcert -version
```

## Next

Go back to the [README](../README.md#quick-start) and continue with step 2 (clone the repo).
