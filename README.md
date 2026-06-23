# e2b-linux-local

This is a small single-host Linux deployer for running E2B on an Ubuntu bare-metal host.

It covers two phases:

1. Repeatable local Linux setup: preflight, dependencies, runtime artifacts, local infra, base template.
2. systemd services: orchestrator, API, and client proxy run in the background.

It intentionally does not try to replace E2B's AWS/GCP Terraform providers yet. Instead, it gives the single-host path a more IaC-like lifecycle: `init`, `plan`, `apply`, `status`, and `destroy`.

## Assumptions

- E2B infra repo is already cloned at a configurable path, for example `/opt/e2b/infra` or `$HOME/src/e2b-infra`.
- The host has `/dev/kvm`, `/dev/net/tun`, cgroup v2, and enough disk.
- Docker is installed and can pull required images.
- You run install scripts on the Ubuntu server.

You can override paths and user by editing:

```bash
/etc/e2b-linux-local.env
```

## Install

Clone this repository on the Ubuntu host:

```bash
mkdir -p ~/src
cd ~/src
git clone https://github.com/zegging/e2b-linux-local.git
cd e2b-linux-local
chmod +x scripts/*.sh
```

Create the env file:

```bash
make init
sudo nano /etc/e2b-linux-local.env
```

At minimum, set the path to your local `e2b-dev/infra` checkout and the seeded local dev API key:

```bash
E2B_ROOT=/path/to/e2b-infra
E2B_API_KEY=<LOCAL_DEV_API_KEY>
```

Run the plan step:

```bash
make plan
```

Install dependencies if needed:

```bash
make install-deps
```

Download E2B runtime artifacts if this is a fresh host:

```bash
make download-artifacts
```

Apply the local deployment:

```bash
make apply
```

This prepares host runtime settings, installs systemd units, enables them, and starts services in the right order.

You can still manage services directly:

```bash
make start
make stop
make restart
make status
```

Follow logs:

```bash
make logs SERVICE=orchestrator
make logs SERVICE=api
make logs SERVICE=client-proxy
```

Build the base template once:

```bash
make build-base
```

Create a sandbox:

```bash
make create-sandbox TIMEOUT=3600
```

From Windows:

```powershell
curl.exe -s -X POST http://<server-ip>:3000/sandboxes `
  -H "X-API-Key: <LOCAL_DEV_API_KEY>" `
  -H "Content-Type: application/json" `
  -d '{\"templateID\":\"base\",\"timeout\":3600}'
```

## Services

The installer creates:

- `e2b-local-infra.service`: Docker Compose services from `packages/local-dev/docker-compose.yaml`
- `e2b-orchestrator.service`: Firecracker orchestrator/template manager
- `e2b-api.service`: local orchestration API
- `e2b-client-proxy.service`: local client proxy

Logs:

```bash
journalctl -u e2b-orchestrator -f
journalctl -u e2b-api -f
journalctl -u e2b-client-proxy -f
```

Health:

```bash
curl -s http://localhost:5008/health && echo
curl -s http://localhost:3000/health && echo
curl -s http://localhost:3003/health && echo
```

## IaC Layout

The single-host IaC contract lives in:

```text
iac/linux-local/
```

It contains the public env template and the lifecycle contract for this repository. The top-level `Makefile` is the main operator interface:

```bash
make init
make plan
make apply
make status
make destroy
```

`destroy` stops and disables services but keeps data by default. More destructive modes require explicit environment flags; see `scripts/destroy.sh`.

## Notes

- `local-build-base-template` can be slow the first time. In one run it took about 40 minutes.
- Always pass `timeout` when creating a sandbox. The local default observed during setup was 15 seconds.
- `3000` is the API port.
- `3002` is the sandbox URL for SDK use.
- `3003` is the client proxy health endpoint.
