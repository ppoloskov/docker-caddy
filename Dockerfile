FROM alpine:3.10 
MAINTAINER Paul Poloskov <pavel@poloskov.net>

ARG CADDY_URL="https://caddyserver.com/download/linux/amd64"
ARG PLUGINS="http.geoip,http.ipfilter,http.jwt,http.login"
ARG TELEMETRY="off"

ENV PUID=1001
ENV PGID=1001

ENV TZ "Europe/Moscow"

# Path where certicates are stored
ENV CADDYPATH "/caddy"

RUN apk add --no-cache curl ca-certificates tzdata libcap && \
    cd /tmp && \
    curl -sL "${CADDY_URL}?plugins=${PLUGINS}&license=personal&telemetry=${TELEMETRY}" | tar xz && \
    mv /tmp/caddy /opt && rm -rf /tmp/* && \
    setcap 'cap_net_bind_service=+ep' /opt/caddy && \
    addgroup -g ${PGID} notroot && \
    adduser -D -h /caddy -G notroot -u ${PUID} notroot && \
    echo -e '<html><body><h1>Hello! My name is elder Caddy!</h1></body></html>' > /srv/index.html && \
    chown -R notroot:notroot /caddy /srv && \
    apk del curl libcap

# Use an unprivileged user.
USER notroot

EXPOSE 80 443 2015

HEALTHCHECK CMD netstat -an | grep 80 > /dev/null; if [ 0 != $? ]; then exit 1; fi;

VOLUME /caddy /srv

ENTRYPOINT ["/opt/caddy", "-agree" ]
CMD [ "-log", "stdout", "-root", "/srv"]

