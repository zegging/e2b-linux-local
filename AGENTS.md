# AGENTS.md

Guidance for coding agents working in this repository.

## Project Scope

This repository packages the E2B `DEV-LOCAL.md` bare-metal flow into repeatable Linux scripts, systemd units, and a small single-host IaC lifecycle.

It is intentionally scoped to a single Ubuntu host. Do not expand it into a full AWS/GCP replacement, multi-node Nomad provider, or Terraform provider unless explicitly requested.

The desired operator surface is:

```bash
make init
make plan
make apply
make status
make destroy
```

Prefer improving this lifecycle over adding ad hoc one-off commands.

## Safety And Sanitization

This repository is intended to be shareable. Do not commit:

- Real API keys or access tokens.
- Internal IP addresses.
- Personal usernames or home-directory paths.
- Concrete sandbox IDs, template IDs, build IDs, team IDs, or trace IDs copied from a private runtime.
- Local logs, pid files, generated env files, or temporary runtime output.

Use placeholders such as:

```text
<server-ip>
<user>
<LOCAL_DEV_API_KEY>
/path/to/e2b-infra
```

Before committing, run:

```bash
rg -n "([0-9]{1,3}\\.){3}[0-9]{1,3}|/home/[^/ ]+|e2b_[A-Za-z0-9_]+|sk_e2b_[A-Za-z0-9_]+|sandboxID|team.id|trace_id" .
```

Review each hit and keep only generic examples or code identifiers.

## Line Endings

Shell scripts and systemd units must use LF line endings. Keep `.gitattributes` intact:

```text
*.sh text eol=lf
*.service text eol=lf
```

## Expected Validation

For shell-only edits, run:

```bash
make validate
```

For documentation edits, scan for secrets and placeholders:

```bash
rg -n "([0-9]{1,3}\\.){3}[0-9]{1,3}|/home/[^/ ]+|e2b_[A-Za-z0-9_]+|sk_e2b_[A-Za-z0-9_]+" .
```

For service changes, inspect rendered units after `scripts/install-systemd.sh` on a Linux host before trusting them.

For IaC lifecycle changes, update both `README.md` and `iac/linux-local/README.md`.

## Operational Notes

- The base template build can take a long time on first run.
- Sandbox creation should pass an explicit `timeout`.
- `3000` is the API port.
- `3002` is the sandbox URL used by SDK clients.
- `3003` is the client proxy health endpoint.
