# doxstation-proxy

Public nginx for **doxstation.com** hostnames. This repo owns **:80 / :443**.

App stacks stay in their own folders. Proxy changes happen here, not in AI Code Player.

| Host | Upstream on the VPS |
|------|---------------------|
| `play.doxstation.com` | UI `:3010`, API `:8010` (AI Code Player) |
| `doxstation.com` | web `:3000`, API `:8000` (AI Teacher) |
| `shorts.doxstation.com` | `:3123` |
| `docvault.doxstation.com` | `:8088` |
| `manager.doxstation.com` | `:3050` |
| `quiz.doxstation.com` | `:4173` |
| `toddler.doxstation.com` | `:5174` |
| `techshala.doxstation.com` | `:5175` |

## Deploy

Jenkins job on this repo, or on the VPS:

```bash
cp .env.example .env
docker compose up -d --build
```

`docker compose down` in **ai-coder** must not stop this project (`doxstation`).

## TLS

```bash
bash scripts/deploy.sh
```

HTTP-01 uses `/var/www/html`. Recreate the container after a new cert so `40-https.sh` loads the vhost.
