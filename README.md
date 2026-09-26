# monit-disk-alert

Alpine 기반 컨테이너로 디스크 사용량을 감시하고, 임계치(기본 70%)를 초과하면
Discord 웹훅으로 알림을 보냅니다. busybox의 crond로 지정한 시간대에만,
지정한 주기(기본 매시 정각)로 검사하며, 조건이 계속 유지되면 검사할 때마다
매번 알림이 반복 전송됩니다.

## 사용법

1. 저장소 클론
   ```bash
   git clone https://github.com/본인아이디/monit-disk-alert.git
   cd monit-disk-alert
   ```

2. 환경변수 파일 준비
   ```bash
   cp .env.example .env
   # .env 파일을 열어 DISCORD_WEBHOOK_URL 에 실제 웹훅 주소 입력
   ```

3. 빌드 및 실행
   ```bash
   docker compose up -d --build
   ```

4. 로그 확인
   ```bash
   docker logs -f disk-alert
   ```

## 구조

| 파일 | 설명 |
|---|---|
| `Dockerfile` | Alpine 기반 이미지 빌드 정의 |
| `scripts/check-disk.sh` | 디스크 사용량 검사 및 Discord 알림 전송 |
| `entrypoint.sh` | 크론 스케줄 등록 후 crond 실행 |
| `docker-compose.yml` | 호스트 디스크 마운트 및 환경변수 주입 |

## 환경변수

| 변수 | 기본값 | 설명 |
|---|---|---|
| `DISCORD_WEBHOOK_URL` | (필수) | Discord 웹훅 주소 |
| `DISK_THRESHOLD` | `70` | 알림을 보낼 사용량 임계치(%) |
| `CHECK_PATHS` | `/hostfs` | 검사할 경로들, 콤마로 여러 개 지정 가능 |
| `CRON_SCHEDULE` | `0 0,9-23 * * *` | 검사 주기 (매시 정각, 09시~24시) |

## 여러 파티션 감시하기

호스트에 `/data` 처럼 별도 파티션이 있다면 `docker-compose.yml`에 마운트를
추가하고 `CHECK_PATHS`에 경로를 이어서 적으면 됩니다.

```yaml
volumes:
  - /:/hostfs:ro
  - /data:/hostfs-data:ro
environment:
  - CHECK_PATHS=/hostfs,/hostfs-data
```

## 검사 주기/시간대 변경

`CRON_SCHEDULE` 값을 표준 cron 형식으로 바꾸면 됩니다. 예: 30분마다 검사하려면
`*/30 9-23 * * *`. 컨테이너의 시간대는 `Dockerfile`에서 `TZ=Asia/Seoul`로
고정되어 있습니다.

## 바로 테스트해보기

빌드 직후 `docker compose exec disk-alert /scripts/check-disk.sh` 를 실행하면
크론 스케줄과 무관하게 즉시 한 번 검사하고, 임계치를 넘으면 바로 Discord로
알림이 옵니다.
