# SuiteCRM on Coolify (Per-Client, Clean Domains, GitHub Deploys)

**Patched build**: uses a robust copy method (no rsync) and defaults to `SUITECRM_VERSION=8.8.1`.

One stack per client (full isolation), clean domains (no `:port`),
GitHub-based deploys/rollbacks, all behind **Coolify's Traefik proxy**.

## Quick Start (Git, HTTPS remote)
```bash
git init -b main
git add .
git commit -m "Initial SuiteCRM Coolify stack (patched)"
git remote add origin https://github.com/bizabodedigital-sudo/suitecrm-coolify.git
git push -u origin main
```

## Deploy on Coolify
- Source: GitHub App (bizabodedigital-sudo) → repo `suitecrm-coolify`, branch `main`
- Build pack: Docker Compose (docker-compose.yml)
- Domains: `https://<client-subdomain>.bizabodedigital.com`
- Environment: set DB creds + `SUITECRM_VERSION` (8.8.1 by default)
- Deploy → run SuiteCRM installer → add Trusted Hosts → verify Schedulers
