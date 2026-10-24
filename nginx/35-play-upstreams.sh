#!/bin/sh
# Play vhosts talk to AI Coder through the host ports Jenkins publishes
# (3010 / 8010), never compose DNS names like "backend". That keeps this
# edge proxy up even when the aicoder stack is down or restarting.
set -eu

WEB="${PLAY_WEB_PORT:-3010}"
API="${PLAY_API_PORT:-8010}"

cat > /etc/nginx/conf.d/00-play-upstreams.conf <<EOF
upstream play_web {
    server host.docker.internal:${WEB};
}

upstream play_api {
    server host.docker.internal:${API};
}
EOF

echo "nginx: play upstreams web=host.docker.internal:${WEB} api=host.docker.internal:${API}"
