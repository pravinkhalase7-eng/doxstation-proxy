# doxstation edge proxy

This repository is the public Nginx edge for `doxstation.com`. It is a separate Compose project from AI Code Player. Restarting or redeploying AI Code Player does not recreate this proxy.

The Compose project name is `doxstation`, and the service name is `edge`. That is the project already used on the VPS. A deploy from this directory replaces that edge container only.

Upstream apps stay on their own published host ports. This proxy reaches them through `host.docker.internal`:

| Host | Upstream |
|---|---|
| `play.doxstation.com` | AI Code Player UI `:3010`, API `:8010` |
| `doxstation.com` | AI Teacher web `:3000`, API `:8000` |
| `shorts.doxstation.com` | Short Video Maker `:3123` |
| `docvault.doxstation.com` | DocVault `:8088` (backup `:8089`) |
| `manager.doxstation.com` | Env Manager `:3050` |
| `quiz.doxstation.com` | Ignite Quiz `:4173` |

Certificates stay on the host at `/etc/letsencrypt`. ACME webroot stays at `/var/www/html`. This project mounts both read-only and does not delete them.

## Deploy on the VPS

Do this from a checkout of this repository on the VPS. Do not run it from a laptop unless that machine is the VPS.

```bash
cd /path/to/doxstation-proxy
cp .env.example .env
docker compose -p doxstation config
bash scripts/deploy.sh
```

`scripts/deploy.sh` builds the image, starts project `doxstation`, and requests a Let's Encrypt certificate only when that hostname does not already have one. An existing certificate is left in place when issuance fails.

Check:

```bash
docker compose -p doxstation ps
curl -fsS -H 'Host: play.doxstation.com' http://127.0.0.1/ | head
```

Proxy config changes belong in `nginx/` in this repository. Rebuild with the same command. There is no second listener: ports 80 and 443 stay on this one container.

## What not to do

- Do not start another Nginx on port 80 or 443.
- Do not run `docker compose down` in AI Code Player to change this proxy.
- Do not delete `/etc/letsencrypt` or the existing edge volumes as part of a config edit.

AI Code Player's Jenkins job should deploy only the app on ports 3010 and 8010. After that Jenkinsfile change is pushed, an application deploy leaves this edge running.
