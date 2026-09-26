#!/bin/bash
set -uo pipefail

WEBHOOK_URL="${DISCORD_WEBHOOK_URL:-}"
THRESHOLD="${DISK_THRESHOLD:-70}"
IFS=',' read -ra TARGET_PATHS <<< "${CHECK_PATHS:-/hostfs}"

if [ -z "$WEBHOOK_URL" ]; then
    echo "DISCORD_WEBHOOK_URL 환경변수가 설정되지 않았습니다." >&2
    exit 1
fi

for TARGET in "${TARGET_PATHS[@]}"; do
    if [ ! -d "$TARGET" ]; then
        echo "경로를 찾을 수 없어 건너뜁니다: $TARGET" >&2
        continue
    fi

    read -r USAGE_PCT USED TOTAL <<< "$(df -P "$TARGET" | awk 'NR==2 {gsub("%","",$5); print $5, $3, $2}')"

    if [ -z "$USAGE_PCT" ]; then
        echo "디스크 사용량을 읽을 수 없습니다: $TARGET" >&2
        continue
    fi

    if [ "$USAGE_PCT" -ge "$THRESHOLD" ]; then
        HOST_NAME="$(hostname)"
        TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S %Z')"
        PAYLOAD=$(cat <<PAYLOAD_EOF
{
  "content": "⚠️ **디스크 사용량 경고**\n호스트: \`${HOST_NAME}\`\n경로: \`${TARGET}\`\n사용량: \`${USAGE_PCT}%\` (사용 ${USED}KB / 전체 ${TOTAL}KB)\n임계치: ${THRESHOLD}% 초과\n시간: ${TIMESTAMP}"
}
PAYLOAD_EOF
)
        curl -sf -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$WEBHOOK_URL" \
            || echo "Discord 알림 전송 실패: $TARGET" >&2
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') 정상 - ${TARGET}: ${USAGE_PCT}%"
    fi
done
