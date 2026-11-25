// 배포 게이트: 매년 반복 디데이는 어떤 날에 봐도 D+ 가 나오면 안 된다.
// 실행: sh scripts/predeploy.sh (공유 모델 파일과 함께 swiftc 로 컴파일한다)
import Foundation

let cal = Calendar.current
let start = cal.date(from: DateComponents(year: 2026, month: 1, day: 1))!
var originals: [Date] = []
for y in stride(from: 1950, through: 2030, by: 7) {
    for m in 1...12 {
        for d in [1, 15, 29, 30] {
            if let date = cal.date(from: DateComponents(year: y, month: m, day: d)) { originals.append(date) }
        }
    }
}

var failures = 0
for isLunar in [false, true] {
    for original in originals {
        let item = DDayItem(title: "검사", date: original, repeatsYearly: true, isLunar: isLunar)
        for offset in stride(from: 0, to: 365 * 3, by: 3) {
            let ref = cal.date(byAdding: .day, value: offset, to: start)!.addingTimeInterval(13 * 3600)
            let diff = item.dayDifference(reference: ref)
            if diff < 0 || diff > 400 || item.countText(reference: ref).hasPrefix("D+") {
                failures += 1
                if failures <= 5 { print("❌ 음력=\(isLunar) 원래=\(original) 기준=\(ref) 차이=\(diff)") }
            }
        }
    }
}

if failures > 0 {
    print("❌ 매년 반복 디데이에서 D+ 또는 이상한 값 \(failures)건")
    exit(1)
}
print("✅ 매년 반복 디데이: D+ 없음")
