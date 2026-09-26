#!/bin/sh
set -e

if [ -z "${DISCORD_WEBHOOK_URL:-}" ]; then
    echo "ERROR: DISCORD_WEBHOOK_URL 환경변수가 설정되지 않았습니다." >&2
    exit 1
fi

CRON_SCHEDULE="${CRON_SCHEDULE:-0 0,9-23 * * *}"
echo "${CRON_SCHEDULE} /scripts/check-disk.sh >> /var/log/check-disk.log 2>&1" > /etc/crontabs/root

echo "설정된 크론 스케줄: ${CRON_SCHEDULE} (시간대: ${TZ:-UTC})"
exec crond -f -l 2
