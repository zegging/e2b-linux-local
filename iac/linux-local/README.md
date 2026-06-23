# linux-local IaC Shape

This directory documents the intended single-host IaC contract for this repository.

It is not a full E2B `provider-linux` implementation. It is a local provider-shaped wrapper around the upstream E2B `DEV-LOCAL.md` bare-metal flow.

## Lifecycle

The lifecycle is intentionally close to cloud IaC vocabulary:

```bash
make init
make plan
make apply
make status
make destroy
```

Mapping:

| Target | Meaning |
|---|---|
| `make init` | Create `/etc/e2b-linux-local.env` if missing. |
| `make plan` | Validate host capabilities and print the intended local deployment shape. |
| `make apply` | Prepare kernel settings, install systemd units, enable and start services. |
| `make destroy` | Stop and disable services. Runtime data is kept unless explicitly removed. |
| `make status` | Show systemd status and health endpoints. |

## Configuration

Use `e2b-linux-local.env.example` as the public template. The real config lives at:

```text
/etc/e2b-linux-local.env
```

Do not commit the real env file.

## Current Single-Host Resources

`apply` manages these local resources:

- Host kernel/runtime settings:
  - NBD module
  - hugepages
  - IPv4 forwarding
  - userfaultfd
- Docker Compose local infra:
  - Postgres
  - Redis
  - ClickHouse
  - observability services from upstream local dev compose
- systemd services:
  - `e2b-local-infra`
  - `e2b-orchestrator`
  - `e2b-api`
  - `e2b-client-proxy`

## Out Of Scope

These belong to a future real `provider-linux`:

- Multi-node scheduling.
- Nomad/Consul cluster provisioning.
- DNS/TLS automation.
- External object storage or MinIO.
- Registry management.
- Secrets backend integration.
- Network ingress and wildcard sandbox domains.
