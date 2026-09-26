#!/bin/sh
set -e

if [ -z "${DISCORD_WEBHOOK_URL:-}" ]; then
    echo "ERROR: DISCORD_WEBHOOK_URL 환경변수가 설정되지 않았습니다." >&2
    exit 1
fi

# 컨테이너 시작 직후 네트워크가 아직 준비되지 않았을 수 있으므로,
# 실제로 외부 연결이 되는지 확인될 때까지 최대 MAX_WAIT초 동안 대기한다.
MAX_WAIT=30
WAITED=0
until curl -s --max-time 3 -o /dev/null https://discord.com; do
    if [ "$WAITED" -ge "$MAX_WAIT" ]; then
        echo "경고: ${MAX_WAIT}초 동안 네트워크 연결을 확인하지 못했습니다. 일단 진행합니다." >&2
        break
    fi
    echo "네트워크 준비 대기 중... (${WAITED}s)"
    sleep 2
    WAITED=$((WAITED + 2))
done

CRON_SCHEDULE="${CRON_SCHEDULE:-0 0,9-23 * * *}"
echo "${CRON_SCHEDULE} /scripts/check-disk.sh >> /var/log/check-disk.log 2>&1" > /etc/crontabs/root

echo "설정된 크론 스케줄: ${CRON_SCHEDULE} (시간대: ${TZ:-UTC})"
exec crond -f -l 2
