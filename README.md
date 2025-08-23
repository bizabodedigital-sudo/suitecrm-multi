# SuiteCRM on Coolify (Per-Client, Clean Domains, GitHub Deploys)

One stack per client (full isolation), clean domains (no `:port`),
GitHub-based deploys/rollbacks, all behind **Coolify's Traefik proxy**.

## What you get
- **Per-client isolation**: each client is a separate Coolify Project & Compose stack.
- **Clean HTTPS domains**: set FQDNs in Coolify; Traefik handles routing + certs.
- **GitHub deploys**: push changes to repo → Deploy; use Deployment history to roll back.
- **Official SuiteCRM layout**: Apache + PHP 8.2, DocumentRoot at `/public`, cron every minute.

---

## 1) Fork or use as a template
1. Click **Use this template** on GitHub, or fork the repo.
2. (Optional) Set your default SuiteCRM version in `.env.example` → `SUITECRM_VERSION`.

## 2) Coolify setup (one project per client)
1. In Coolify **Settings → Sources**, connect a **GitHub App**.
2. Create a **Project** (e.g., `client-acme`).
3. **Add Resource → Application → Docker Compose (from Git)**, select this repo/branch.
4. In the app's **Environment** tab, add any secrets/overrides (`DB_PASSWORD`, etc.).
5. In the app's **Domains** tab, set your FQDN (e.g., `https://crm.acme.yourdomain.com`).
   - Update public DNS A/AAAA records to point to your Coolify server.
6. **Deploy**.

Coolify builds the image, creates isolated network/volumes, and routes via Traefik.
You do **not** need to publish any ports in `docker-compose.yml`.

> Note: Coolify does not support *rolling updates* for Docker Compose apps.
> You can still re-deploy any prior commit from the Deployments tab.

## 3) First-run install
- Browse to your domain. The SuiteCRM installer will guide you through DB & admin setup.
- Or use the Coolify Terminal and run the **CLI installer** if preferred.

### Fix permissions after install (inside the app container)
```bash
cd /var/www/html
find . -type d -not -perm 2755 -exec chmod 2755 {} \;
find . -type f -not -perm 0644 -exec chmod 0644 {} \;
find . ! -user www-data -exec chown www-data:www-data {} \;
chmod +x bin/console
```

### Trusted hosts
Add your domain to SuiteCRM **trusted hosts** so proxy Host headers are accepted.
See: `config.php` → `trusted_hosts`.

### Scheduler (cron)
A small sidecar container (`cron`) runs `public/legacy/cron.php` every minute, as required by SuiteCRM schedulers.

## 4) Updates & rollbacks
- Push to your repo → Deploy in Coolify.
- To rollback, open **Deployments** in the app and redeploy a previous commit.

---

## Variables
See `.env.example` for defaults. Override in Coolify (Environment tab) as needed.

| Variable           | Default     | Notes                          |
|--------------------|-------------|--------------------------------|
| SUITECRM_VERSION   | `8.7.1`     | Tag from SuiteCRM releases     |
| DB_NAME            | `suitecrm`  | MariaDB database name          |
| DB_USER            | `suitecrm`  | MariaDB user                   |
| DB_PASSWORD        | `changeme`  | MariaDB user password          |
| DB_ROOT_PASSWORD   | `changemeroot` | MariaDB root password      |

---

## References (official docs)
- SuiteCRM 8 Webserver setup (Apache + /public)
- SuiteCRM 8 Compatibility (PHP 8.1–8.3)
- SuiteCRM-Core Releases (pick a version tag)
- Scheduler/cron (legacy cron.php still used)
- Coolify: GitHub integration, Compose apps, Domains (Traefik)
# suitecrm-multi
# suitecrm-multi
# suitecrm-multi
