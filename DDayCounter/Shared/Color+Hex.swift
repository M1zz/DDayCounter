//
//  Color+Hex.swift
//  DDayCounter
//
//  Hex 문자열 <-> SwiftUI Color 변환 헬퍼 (앱 / 위젯 공용)
//

import SwiftUI

extension Color {
    /// "#RRGGBB" 또는 "RRGGBB" 형식의 hex 문자열로 Color 생성
    init?(hex: String) {
        var str = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if str.hasPrefix("#") { str.removeFirst() }
        guard str.count == 6, let value = UInt64(str, radix: 16) else { return nil }
        let r = Double((value & 0xFF0000) >> 16) / 255.0
        let g = Double((value & 0x00FF00) >> 8) / 255.0
        let b = Double(value & 0x0000FF) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }
}

/// 팔레트 - 새 디데이 추가 시 선택할 수 있는 색상들
enum DDayPalette {
    static let colors: [String] = [
        "#4C6EF5", // 인디고
        "#FF6B6B", // 레드
        "#F59F00", // 오렌지
        "#40C057", // 그린
        "#7048E8", // 퍼플
        "#1098AD", // 틸
        "#E64980", // 핑크
        "#212529"  // 블랙
    ]

    static let symbols: [String] = [
        "🎯", "📚", "❤️", "🎂", "✈️", "💍", "🎓", "🏆",
        "🍼", "🎄", "🎉", "💼", "🏥", "🐣", "🌸", "⭐️"
    ]
}
