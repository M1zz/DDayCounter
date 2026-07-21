//
//  DDayProvider.swift
//  DDayWidget
//
//  타임라인 공급자 - 자정마다 카운트가 갱신되도록 엔트리를 생성합니다.
//

import WidgetKit
import SwiftUI

struct DDayEntry: TimelineEntry {
    let date: Date
    let item: DDayItem?
}

struct DDayProvider: AppIntentTimelineProvider {
    typealias Entry = DDayEntry
    typealias Intent = SelectDDayIntent

    func placeholder(in context: Context) -> DDayEntry {
        DDayEntry(date: Date(), item: .sample)
    }

    func snapshot(for configuration: SelectDDayIntent, in context: Context) async -> DDayEntry {
        DDayEntry(date: Date(), item: resolveItem(configuration))
    }

    func timeline(for configuration: SelectDDayIntent, in context: Context) async -> Timeline<DDayEntry> {
        let item = resolveItem(configuration)
        let cal = Calendar.current
        let now = Date()
        var entries: [DDayEntry] = []

        // 오늘 + 향후 7일의 자정 시점 엔트리를 만들어 날짜가 바뀌면 자동으로 카운트가 갱신되게 함
        entries.append(DDayEntry(date: now, item: item))
        let startOfToday = cal.startOfDay(for: now)
        for dayOffset in 1...7 {
            if let midnight = cal.date(byAdding: .day, value: dayOffset, to: startOfToday) {
                entries.append(DDayEntry(date: midnight, item: item))
            }
        }

        // 마지막 엔트리 다음날 다시 타임라인 요청
        let refresh = cal.date(byAdding: .day, value: 8, to: startOfToday) ?? now.addingTimeInterval(86_400)
        return Timeline(entries: entries, policy: .after(refresh))
    }

    /// 구성에서 선택된 디데이(없으면 고정/첫 항목)를 반환
    private func resolveItem(_ configuration: SelectDDayIntent) -> DDayItem? {
        let items = DDayStore.loadItemsForWidget()
        if let id = configuration.dday?.id, let match = items.first(where: { $0.id == id }) {
            return match
        }
        if let pinned = DDayStore.loadPinnedIDForWidget(),
           let match = items.first(where: { $0.id == pinned }) {
            return match
        }
        return items.first
    }
}
