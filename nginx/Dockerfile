# Bake vhost config into the image. Jenkins-in-Docker + host docker.sock cannot
# bind-mount ./deploy/edge.d from the Jenkins workspace path.
FROM nginx:1.27-alpine
COPY default.conf /etc/nginx/conf.d/default.conf
COPY play.inc /etc/nginx/play.inc
COPY https.conf.template /etc/nginx/templates-extra/https.conf.template
COPY https-default.conf.template /etc/nginx/templates-extra/https-default.conf.template
COPY https-aiteacher.conf.template /etc/nginx/templates-extra/https-aiteacher.conf.template
COPY https-shortvideo.conf.template /etc/nginx/templates-extra/https-shortvideo.conf.template
COPY https-docvault.conf.template /etc/nginx/templates-extra/https-docvault.conf.template
COPY https-envmanager.conf.template /etc/nginx/templates-extra/https-envmanager.conf.template
COPY 35-play-upstreams.sh /docker-entrypoint.d/35-play-upstreams.sh
COPY 40-https.sh /docker-entrypoint.d/40-https.sh
RUN chmod +x /docker-entrypoint.d/35-play-upstreams.sh /docker-entrypoint.d/40-https.sh
