//
//  LunarCalendar.swift
//  DDayCounter
//
//  음력(한국 음력 = 중국력) 변환 헬퍼 (앱 / 위젯 공용)
//  iOS의 Calendar(identifier: .chinese)를 이용해 양력 ↔ 음력을 변환합니다.
//

import Foundation

/// 전역 달력 모드 (앱 시작 시 사용자가 선택)
enum CalendarMode: String, Codable, CaseIterable, Identifiable {
    case solar   // 양력
    case lunar   // 음력

    var id: String { rawValue }

    var title: String {
        switch self {
        case .solar: return "양력"
        case .lunar: return "음력"
        }
    }

    var isLunar: Bool { self == .lunar }
}

/// 한국 음력(중국력) 변환 유틸리티
enum KoreanLunar {

    /// 중국력(음력) 캘린더
    private static var chinese: Calendar {
        Calendar(identifier: .chinese)
    }

    /// 양력 날짜의 음력 구성 요소 (월/일/윤달 여부)
    static func components(from date: Date) -> (month: Int, day: Int, isLeap: Bool) {
        let comps = chinese.dateComponents([.month, .day], from: date)
        return (comps.month ?? 0, comps.day ?? 0, comps.isLeapMonth ?? false)
    }

    /// 특정 양력 연도에서 주어진 음력 월/일에 해당하는 양력 날짜를 계산
    static func solarDate(lunarMonth month: Int,
                          lunarDay day: Int,
                          isLeap: Bool,
                          gregorianYear year: Int) -> Date? {
        let gregorian = Calendar(identifier: .gregorian)
        // 해당 양력 연도의 중간 지점에서 중국력 연/사이클 값을 얻는다 (설 이후를 보장)
        guard let midYear = gregorian.date(from: DateComponents(year: year, month: 7, day: 1)) else {
            return nil
        }
        let era = chinese.component(.era, from: midYear)
        let cyclicYear = chinese.component(.year, from: midYear)

        var lunar = DateComponents()
        lunar.era = era
        lunar.year = cyclicYear
        lunar.month = month
        lunar.day = day
        lunar.isLeapMonth = isLeap
        return chinese.date(from: lunar)
    }

    /// 주어진 양력 연도에서 음력 월/일의 "실제" 발생일을 계산.
    /// 윤달이 없는 해나 해당 일이 존재하지 않는 달(29일)까지 안전하게 보정한다.
    static func occurrence(month: Int,
                           day: Int,
                           isLeap: Bool,
                           inGregorianYear year: Int) -> Date? {
        let leapOptions = isLeap ? [true, false] : [false]
        for leap in leapOptions {
            // day가 30인데 그 달이 29일까지만 있는 경우 29일로 보정
            for candidateDay in stride(from: day, through: 29, by: -1) {
                if let date = solarDate(lunarMonth: month, lunarDay: candidateDay,
                                        isLeap: leap, gregorianYear: year) {
                    let check = components(from: date)
                    if check.month == month && check.day == candidateDay {
                        return date
                    }
                }
            }
        }
        return nil
    }

    /// 해당 양력 연도에 주어진 음력 월의 윤달이 존재하는지 여부
    static func leapMonthExists(month: Int, gregorianYear year: Int) -> Bool {
        guard let d = solarDate(lunarMonth: month, lunarDay: 1, isLeap: true, gregorianYear: year) else {
            return false
        }
        let c = components(from: d)
        return c.month == month && c.isLeap
    }

    /// 양력 날짜를 "음력 O월 O일" 형태의 문자열로 변환 (윤달이면 "윤" 접두)
    static func lunarString(from date: Date, includeYear: Bool = false) -> String {
        let comps = chinese.dateComponents([.year, .month, .day], from: date)
        let month = comps.month ?? 0
        let day = comps.day ?? 0
        let leap = (comps.isLeapMonth ?? false) ? "윤" : ""
        if includeYear {
            return "음력 \(comps.year ?? 0)년 \(leap)\(month)월 \(day)일"
        }
        return "음력 \(leap)\(month)월 \(day)일"
    }
}
