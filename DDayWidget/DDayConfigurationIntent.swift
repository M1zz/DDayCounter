//
//  DDayConfigurationIntent.swift
//  DDayWidget
//
//  위젯을 길게 눌러 "표시할 디데이"를 선택할 수 있게 하는 App Intent 설정
//

import AppIntents
import WidgetKit

/// 위젯에서 선택 가능한 디데이 항목
struct DDayEntity: AppEntity, Identifiable {
    var id: UUID
    var title: String
    var symbol: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "디데이"
    static var defaultQuery = DDayEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(symbol) \(title)")
    }
}

/// 저장소에서 디데이 목록을 읽어 선택지로 제공
struct DDayEntityQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [DDayEntity] {
        DDayStore.loadItemsForWidget()
            .filter { identifiers.contains($0.id) }
            .map { DDayEntity(id: $0.id, title: $0.title, symbol: $0.symbol) }
    }

    func suggestedEntities() async throws -> [DDayEntity] {
        DDayStore.loadItemsForWidget()
            .map { DDayEntity(id: $0.id, title: $0.title, symbol: $0.symbol) }
    }
}

// 참고: 위젯에서 디데이를 고르지 않았을 때(dday == nil)는
// DDayProvider.resolveItem 이 "앱에서 고정한 디데이 → 첫 항목" 순으로 기본값을 채웁니다.

/// 위젯 구성 인텐트
struct SelectDDayIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "디데이 선택"
    static var description = IntentDescription("위젯에 표시할 디데이를 선택하세요.")

    @Parameter(title: "디데이")
    var dday: DDayEntity?

    init() {}

    init(dday: DDayEntity?) {
        self.dday = dday
    }
}
