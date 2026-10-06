//
//  DDayWidgetViews.swift
//  DDayWidget
//
//  홈 화면 / 잠금 화면 위젯의 뷰
//

import WidgetKit
import SwiftUI

/// 위젯 패밀리에 따라 알맞은 레이아웃을 그리는 진입 뷰
struct DDayWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: DDayProvider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            HomeSmallView(entry: entry)
        case .systemMedium:
            HomeMediumView(entry: entry)
        case .accessoryCircular:
            LockCircularView(entry: entry)
        case .accessoryRectangular:
            LockRectangularView(entry: entry)
        case .accessoryInline:
            LockInlineView(entry: entry)
        default:
            HomeSmallView(entry: entry)
        }
    }
}

// MARK: - 홈 화면 (Small)

struct HomeSmallView: View {
    let entry: DDayProvider.Entry

    var body: some View {
        if let item = entry.item {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.symbol).font(.title3)
                    Spacer()
                    if !item.relation.isEmpty {
                        WidgetRelationTag(item: item)
                    }
                }
                Spacer()
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(item.countText(reference: entry.date))
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(item.color)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text(item.dateText(reference: entry.date))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .containerBackground(for: .widget) { item.color.opacity(0.10) }
        } else {
            EmptyWidgetView()
        }
    }
}

// MARK: - 홈 화면 (Medium)

struct HomeMediumView: View {
    let entry: DDayProvider.Entry

    var body: some View {
        if let item = entry.item {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(item.color.opacity(0.18))
                    Text(item.symbol).font(.system(size: 40))
                }
                .frame(width: 92, height: 92)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        if !item.relation.isEmpty {
                            WidgetRelationTag(item: item)
                        }
                        Text(item.title)
                            .font(.headline)
                            .lineLimit(1)
                    }
                    Text(item.countText(reference: entry.date))
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(item.color)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    Text(item.dateText(reference: entry.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .containerBackground(for: .widget) { item.color.opacity(0.10) }
        } else {
            EmptyWidgetView()
        }
    }
}

// MARK: - 잠금 화면 (원형)

struct LockCircularView: View {
    let entry: DDayProvider.Entry

    var body: some View {
        if let item = entry.item {
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Text(item.symbol).font(.system(size: 13))
                    Text(shortCount(item))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
            }
            .containerBackground(for: .widget) { Color.clear }
        } else {
            Image(systemName: "calendar").containerBackground(for: .widget) { Color.clear }
        }
    }

    private func shortCount(_ item: DDayItem) -> String {
        item.countText(reference: entry.date)
    }
}

// MARK: - 잠금 화면 (직사각형)

struct LockRectangularView: View {
    let entry: DDayProvider.Entry

    var body: some View {
        if let item = entry.item {
            HStack(spacing: 8) {
                Text(item.symbol).font(.title3)
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.title)
                        .font(.headline)
                        .lineLimit(1)
                    Text(item.countText(reference: entry.date))
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .lineLimit(1)
                    Text(item.dateText(reference: entry.date))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .containerBackground(for: .widget) { Color.clear }
        } else {
            Text("디데이 없음").containerBackground(for: .widget) { Color.clear }
        }
    }
}

// MARK: - 잠금 화면 (인라인, 시계 위)

struct LockInlineView: View {
    let entry: DDayProvider.Entry

    var body: some View {
        if let item = entry.item {
            Label("\(item.title) \(item.countText(reference: entry.date))",
                  systemImage: "calendar")
        } else {
            Text("디데이를 추가하세요")
        }
    }
}

// MARK: - 관계 태그

struct WidgetRelationTag: View {
    let item: DDayItem

    var body: some View {
        Text(item.relation)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(item.color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(item.color.opacity(0.18)))
            .lineLimit(1)
            .fixedSize()
    }
}

// MARK: - 데이터 없음

struct EmptyWidgetView: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "calendar.badge.plus")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("앱에서 디데이를\n추가하세요")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}
