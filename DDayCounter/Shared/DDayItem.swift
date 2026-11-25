//
//  DDayItem.swift
//  DDayCounter
//
//  공유 모델 - 앱과 위젯 익스텐션에서 함께 사용합니다.
//

import Foundation
import SwiftUI

/// 디데이 카운트 방식
enum DDayCountStyle: String, Codable, CaseIterable, Identifiable {
    /// 목표일까지 남은/지난 일수 (D-30, D-DAY, D+5)
    case dday
    /// 시작일로부터 누적된 일수 (100일, 1일)
    case cumulative

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dday: return "디데이 (D-day)"
        case .cumulative: return "누적일 (며칠째)"
        }
    }
}

/// 디데이에 붙일 수 있는 관계 프리셋 (직접 입력도 가능)
enum DDayRelation {
    struct Group: Identifiable {
        let title: String
        let relations: [String]
        var id: String { title }
    }

    static let groups: [Group] = [
        Group(title: "가족", relations: [
            "엄마", "아빠", "할머니", "할아버지", "외할머니", "외할아버지",
            "아내", "남편", "아들", "딸",
            "형", "오빠", "누나", "언니", "동생",
            "이모", "고모", "삼촌", "외삼촌",
            "시어머니", "시아버지", "장모님", "장인어른", "손주"
        ]),
        Group(title: "지인", relations: [
            "연인", "친구", "동료", "선배", "후배", "선생님", "반려동물"
        ])
    ]
}

/// 하나의 디데이 이벤트
struct DDayItem: Codable, Identifiable, Hashable {
    var id: UUID
    /// 이벤트 제목 (예: "수능", "우리 기념일")
    var title: String
    /// 기준 날짜
    var date: Date
    /// 카운트 방식
    var style: DDayCountStyle
    /// 강조 색상 (hex 문자열, 예: "#FF6B6B")
    var colorHex: String
    /// 이모지 아이콘
    var symbol: String
    /// 매년 반복 여부 (생일, 기념일 등)
    var repeatsYearly: Bool
    /// 음력 날짜 여부 (true면 date를 음력으로 해석·표시하고, 반복 시 음력 기준으로 계산)
    var isLunar: Bool
    /// 이 디데이와 관련된 사람과의 관계 (예: "엄마", "친구"). 빈 문자열이면 없음
    var relation: String
    /// 생성 시각 (정렬용)
    var createdAt: Date

    init(id: UUID = UUID(),
         title: String,
         date: Date,
         style: DDayCountStyle = .dday,
         colorHex: String = "#4C6EF5",
         symbol: String = "🎯",
         repeatsYearly: Bool = false,
         isLunar: Bool = false,
         relation: String = "",
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.date = date
        self.style = style
        self.colorHex = colorHex
        self.symbol = symbol
        self.repeatsYearly = repeatsYearly
        self.isLunar = isLunar
        self.relation = relation
        self.createdAt = createdAt
    }

    // 기존에 저장된 데이터(isLunar·relation 필드 없음)와의 호환을 위한 디코딩
    enum CodingKeys: String, CodingKey {
        case id, title, date, style, colorHex, symbol, repeatsYearly, isLunar, relation, createdAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        date = try c.decode(Date.self, forKey: .date)
        style = try c.decode(DDayCountStyle.self, forKey: .style)
        colorHex = try c.decode(String.self, forKey: .colorHex)
        symbol = try c.decode(String.self, forKey: .symbol)
        repeatsYearly = try c.decode(Bool.self, forKey: .repeatsYearly)
        isLunar = try c.decodeIfPresent(Bool.self, forKey: .isLunar) ?? false
        relation = try c.decodeIfPresent(String.self, forKey: .relation) ?? ""
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}

// MARK: - 날짜 계산

extension DDayItem {

    /// 반복 옵션을 고려한 기준 날짜.
    /// 매년 반복이면 오늘 이후(오늘 포함) 가장 가까운 발생일이라 D+ 가 나오지 않는다.
    func effectiveDate(reference: Date = Date()) -> Date {
        guard repeatsYearly else { return date }
        let cal = Calendar.current
        let today = cal.startOfDay(for: reference)
        let year = cal.component(.year, from: reference)

        // 음력 11·12월은 양력으로 다음 해 1·2월에 오므로 전년부터 몇 해를 넉넉히 보고
        // 오늘 이후 가장 가까운 날을 고른다.
        let lunar = isLunar ? KoreanLunar.components(from: date) : nil
        let solar = cal.dateComponents([.month, .day], from: date)
        let next = (year - 1...year + 2)
            .compactMap { y -> Date? in
                if let lunar {
                    return KoreanLunar.occurrence(month: lunar.month, day: lunar.day,
                                                  isLeap: lunar.isLeap, inGregorianYear: y)
                }
                return cal.date(from: DateComponents(year: y, month: solar.month, day: solar.day))
            }
            .filter { cal.startOfDay(for: $0) >= today }
            .min()
        return next ?? today
    }

    /// 매년 반복 항목에서 다음 발생일이 몇 번째 돌인지 (예: 1960년생의 2026년 생일 → 66).
    /// 기준 날짜가 과거가 아니거나 반복이 아니면 nil
    func nextAnniversaryCount(reference: Date = Date()) -> Int? {
        guard repeatsYearly else { return nil }
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: cal.startOfDay(for: date),
                                      to: cal.startOfDay(for: effectiveDate(reference: reference))).day ?? 0
        // 음력은 양력 날짜가 해마다 3~4주씩 흔들리므로 연 단위로 반올림해 센다
        let years = Int((Double(days) / 365.2425).rounded())
        return years > 0 ? years : nil
    }

    /// 기준일과 목표일 사이의 일수 (양수 = 미래, 0 = 오늘, 음수 = 과거)
    func dayDifference(reference: Date = Date()) -> Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: reference)
        let end = cal.startOfDay(for: effectiveDate(reference: reference))
        return cal.dateComponents([.day], from: start, to: end).day ?? 0
    }

    /// 화면/위젯에 표시할 짧은 카운트 문자열 (예: "D-30", "D-DAY", "D+5", "100일")
    func countText(reference: Date = Date()) -> String {
        let diff = dayDifference(reference: reference)
        switch style {
        case .dday:
            if diff > 0 { return "D-\(diff)" }
            if diff == 0 { return "D-DAY" }
            return "D+\(-diff)"
        case .cumulative:
            // 시작일이 오늘이면 1일째로 표기 (한국식 카운트)
            let cal = Calendar.current
            let start = cal.startOfDay(for: date)
            let today = cal.startOfDay(for: reference)
            let days = (cal.dateComponents([.day], from: start, to: today).day ?? 0) + 1
            if days >= 1 {
                return "\(days)일"
            } else {
                // 아직 시작 전
                return "D\(days - 1)"
            }
        }
    }

    /// 양력 날짜 문자열 (예: "2026년 11월 19일 (목)")
    func solarDateText(reference: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        return formatter.string(from: effectiveDate(reference: reference))
    }

    /// 음력 날짜 문자열 (음력 항목일 때만, 예: "음력 8월 15일")
    func lunarText(reference: Date = Date()) -> String? {
        guard isLunar else { return nil }
        return KoreanLunar.lunarString(from: effectiveDate(reference: reference))
    }

    /// 보조 설명 (예: "2026년 11월 19일 (목)", 음력이면 "음력 8월 15일 · 2026년 …")
    func dateText(reference: Date = Date()) -> String {
        let solar = solarDateText(reference: reference)
        if let lunar = lunarText(reference: reference) {
            return "\(lunar) · \(solar)"
        }
        return solar
    }

    var color: Color {
        Color(hex: colorHex) ?? Color(hex: "#4C6EF5")!
    }
}

// MARK: - 샘플 데이터

extension DDayItem {
    static let sample = DDayItem(
        title: "수능",
        date: Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 19)) ?? Date(),
        style: .dday,
        colorHex: "#4C6EF5",
        symbol: "📚"
    )

    static let samples: [DDayItem] = [
        DDayItem(title: "수능",
                 date: Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 19)) ?? Date(),
                 style: .dday, colorHex: "#4C6EF5", symbol: "📚"),
        DDayItem(title: "우리 기념일",
                 date: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 14)) ?? Date(),
                 style: .cumulative, colorHex: "#FF6B6B", symbol: "❤️"),
        DDayItem(title: "생일",
                 date: Calendar.current.date(from: DateComponents(year: 1995, month: 8, day: 2)) ?? Date(),
                 style: .dday, colorHex: "#F59F00", symbol: "🎂", repeatsYearly: true)
    ]
}
