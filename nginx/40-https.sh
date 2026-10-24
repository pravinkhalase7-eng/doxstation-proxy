#!/bin/sh
# Enable TLS when Let's Encrypt files are already on the host volume.
set -eu

DOMAIN="${NGINX_SERVER_NAME:-play.doxstation.com}"
DOMAIN="${DOMAIN#https://}"
DOMAIN="${DOMAIN#http://}"
DOMAIN="${DOMAIN%%/*}"
DOMAIN="${DOMAIN%%:*}"

CERT="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
KEY="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"
TPL="/etc/nginx/templates-extra/https.conf.template"
OUT="/etc/nginx/conf.d/10-https.conf"

if [ -n "$DOMAIN" ] && [ -f "$CERT" ] && [ -f "$KEY" ] && [ -f "$TPL" ]; then
  sed "s/__DOMAIN__/${DOMAIN}/g" "$TPL" > "$OUT"
  echo "nginx: HTTPS enabled for ${DOMAIN}"
else
  rm -f "$OUT"
  echo "nginx: HTTP only for play (no cert yet for ${DOMAIN:-unknown})"
fi

DEFAULT_TPL="/etc/nginx/templates-extra/https-default.conf.template"
DEFAULT_OUT="/etc/nginx/conf.d/00-https-default.conf"
if [ -f "$CERT" ] && [ -f "$KEY" ] && [ -f "$DEFAULT_TPL" ]; then
  cp "$DEFAULT_TPL" "$DEFAULT_OUT"
  echo "nginx: HTTPS default_server rejects unknown hostnames"
else
  rm -f "$DEFAULT_OUT"
fi

# Apex doxstation.com → AI Teacher (separate cert + vhost).
AITEACHER_TPL="/etc/nginx/templates-extra/https-aiteacher.conf.template"
AITEACHER_OUT="/etc/nginx/conf.d/20-https-aiteacher.conf"
AITEACHER_CERT="/etc/letsencrypt/live/doxstation.com/fullchain.pem"
AITEACHER_KEY="/etc/letsencrypt/live/doxstation.com/privkey.pem"

if [ -f "$AITEACHER_CERT" ] && [ -f "$AITEACHER_KEY" ] && [ -f "$AITEACHER_TPL" ]; then
  cp "$AITEACHER_TPL" "$AITEACHER_OUT"
  echo "nginx: HTTPS enabled for doxstation.com (AI Teacher)"
else
  rm -f "$AITEACHER_OUT"
  echo "nginx: HTTP only for doxstation.com (no cert yet)"
fi

# shorts.doxstation.com → Short Video Maker (separate cert + vhost).
SHORTVIDEO_TPL="/etc/nginx/templates-extra/https-shortvideo.conf.template"
SHORTVIDEO_OUT="/etc/nginx/conf.d/30-https-shortvideo.conf"
SHORTVIDEO_CERT="/etc/letsencrypt/live/shorts.doxstation.com/fullchain.pem"
SHORTVIDEO_KEY="/etc/letsencrypt/live/shorts.doxstation.com/privkey.pem"

if [ -f "$SHORTVIDEO_CERT" ] && [ -f "$SHORTVIDEO_KEY" ] && [ -f "$SHORTVIDEO_TPL" ]; then
  cp "$SHORTVIDEO_TPL" "$SHORTVIDEO_OUT"
  echo "nginx: HTTPS enabled for shorts.doxstation.com (Short Video Maker)"
else
  rm -f "$SHORTVIDEO_OUT"
  echo "nginx: HTTP only for shorts.doxstation.com (no cert yet)"
fi

# docvault.doxstation.com → DocVault (separate cert + vhost).
DOCVAULT_TPL="/etc/nginx/templates-extra/https-docvault.conf.template"
DOCVAULT_OUT="/etc/nginx/conf.d/40-https-docvault.conf"
DOCVAULT_CERT="/etc/letsencrypt/live/docvault.doxstation.com/fullchain.pem"
DOCVAULT_KEY="/etc/letsencrypt/live/docvault.doxstation.com/privkey.pem"

if [ -f "$DOCVAULT_CERT" ] && [ -f "$DOCVAULT_KEY" ] && [ -f "$DOCVAULT_TPL" ]; then
  cp "$DOCVAULT_TPL" "$DOCVAULT_OUT"
  echo "nginx: HTTPS enabled for docvault.doxstation.com (DocVault)"
else
  rm -f "$DOCVAULT_OUT"
  echo "nginx: HTTP only for docvault.doxstation.com (no cert yet)"
fi

# manager.doxstation.com → Env Manager (separate cert + vhost).
ENVMANAGER_TPL="/etc/nginx/templates-extra/https-envmanager.conf.template"
ENVMANAGER_OUT="/etc/nginx/conf.d/50-https-envmanager.conf"
ENVMANAGER_CERT="/etc/letsencrypt/live/manager.doxstation.com/fullchain.pem"
ENVMANAGER_KEY="/etc/letsencrypt/live/manager.doxstation.com/privkey.pem"

if [ -f "$ENVMANAGER_CERT" ] && [ -f "$ENVMANAGER_KEY" ] && [ -f "$ENVMANAGER_TPL" ]; then
  cp "$ENVMANAGER_TPL" "$ENVMANAGER_OUT"
  echo "nginx: HTTPS enabled for manager.doxstation.com (Env Manager)"
else
  rm -f "$ENVMANAGER_OUT"
  echo "nginx: HTTP only for manager.doxstation.com (no cert yet)"
fi
