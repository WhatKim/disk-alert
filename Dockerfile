FROM alpine:3.20

RUN apk add --no-cache bash curl coreutils tzdata

ENV TZ=Asia/Seoul

COPY scripts/check-disk.sh /scripts/check-disk.sh
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /scripts/check-disk.sh /entrypoint.sh \
    && mkdir -p /hostfs /etc/crontabs \
    && touch /etc/crontabs/root /var/log/check-disk.log

ENTRYPOINT ["/entrypoint.sh"]
