# DDayCounter TODO

## 완료
- [x] 음력 일정 저장/1년 리셋 버그 수정
  - 원인: `LunarCalendar.occurrence(...)`의 `stride(from: day, through: 29, by: -1)`가
    음력 1~28일에서 빈 배열이 되어 항상 `nil` 반환
  - 영향:
    - `recomputeDateFromLunar()`가 date를 갱신 못 해 음력 선택이 저장 안 됨
    - `effectiveDate` 음력 반복 분기가 과거 date를 그대로 반환 → 날짜가 지나도 리셋 안 됨
  - 수정: `through: 29` → `through: 1` (LunarCalendar.swift)

## 확인 필요
- [ ] 실기기/시뮬레이터에서 음력 반복 생일 추가 후 저장·표시 확인
- [ ] 음력 반복 항목이 발생일 다음날 다음 해 발생일(D-3xx)로 리셋되는지 확인
