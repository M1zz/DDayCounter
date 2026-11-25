#!/bin/sh
# 배포 전 게이트 — 여기서 실패하면 DeployBar 가 아카이브를 만들지 않는다.
# 이 앱의 핵심 약속(매년 반복 디데이는 D+ 가 나오지 않는다)을 공유 모델 코드로 직접 검사한다.
set -e
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT

echo "🧪 디데이 계산 검사"
# 맨 위 코드가 돌려면 파일 이름이 main.swift 여야 한다
cp scripts/check_dday.swift "$OUT/main.swift"
xcrun swiftc -O -o "$OUT/check_dday" \
  DDayCounter/Shared/DDayItem.swift \
  DDayCounter/Shared/LunarCalendar.swift \
  DDayCounter/Shared/Color+Hex.swift \
  "$OUT/main.swift"
"$OUT/check_dday"

echo ""
echo "✅ 게이트 통과 — 배포 가능"
