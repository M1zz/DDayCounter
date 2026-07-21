//
//  DDayWidgetBundle.swift
//  DDayWidget
//
//  위젯 번들 - 홈 화면 위젯과 잠금 화면 위젯을 등록합니다.
//

import WidgetKit
import SwiftUI

@main
struct DDayWidgetBundle: WidgetBundle {
    var body: some Widget {
        DDayHomeWidget()
        DDayLockWidget()
    }
}

/// 홈 화면 위젯 (Small / Medium)
struct DDayHomeWidget: Widget {
    let kind = "DDayHomeWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind,
                               intent: SelectDDayIntent.self,
                               provider: DDayProvider()) { entry in
            DDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("디데이")
        .description("중요한 날까지 남은 일수를 홈 화면에서 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

/// 잠금 화면 위젯 (원형 / 직사각형 / 인라인)
struct DDayLockWidget: Widget {
    let kind = "DDayLockWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind,
                               intent: SelectDDayIntent.self,
                               provider: DDayProvider()) { entry in
            DDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("디데이 (잠금화면)")
        .description("잠금 화면에서 디데이를 확인하세요.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
