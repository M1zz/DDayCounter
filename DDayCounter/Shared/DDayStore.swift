//
//  DDayStore.swift
//  DDayCounter
//
//  App Group 공유 저장소 - 앱에서 저장한 디데이를 위젯이 함께 읽습니다.
//

import Foundation
import WidgetKit

/// 앱과 위젯이 공유하는 상수
enum AppGroup {
    /// App Group ID. Xcode의 Signing & Capabilities > App Groups 값과 반드시 동일해야 합니다.
    static let identifier = "group.com.leeo.DDayCounter"
    /// UserDefaults 저장 키
    static let storageKey = "ddayItems"
    /// 위젯이 표시할 대표 디데이 id 저장 키
    static let pinnedKey = "pinnedDDayID"
}

/// 디데이 데이터를 관리하고 App Group UserDefaults에 영속화하는 저장소
final class DDayStore: ObservableObject {

    static let shared = DDayStore()

    @Published var items: [DDayItem] = [] {
        didSet { persist() }
    }

    /// 위젯 기본 표시용으로 고정한 디데이 id
    @Published var pinnedID: UUID? {
        didSet {
            defaults?.set(pinnedID?.uuidString, forKey: AppGroup.pinnedKey)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private let defaults = UserDefaults(suiteName: AppGroup.identifier)

    private init() {
        load()
    }

    // MARK: - CRUD

    func add(_ item: DDayItem) {
        items.append(item)
        if pinnedID == nil { pinnedID = item.id }
    }

    func update(_ item: DDayItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
    }

    func delete(at offsets: IndexSet) {
        let removed = offsets.map { items[$0].id }
        items.remove(atOffsets: offsets)
        if let pinned = pinnedID, removed.contains(pinned) {
            pinnedID = items.first?.id
        }
    }

    func delete(_ item: DDayItem) {
        items.removeAll { $0.id == item.id }
        if pinnedID == item.id { pinnedID = items.first?.id }
    }

    func item(with id: UUID?) -> DDayItem? {
        guard let id else { return nil }
        return items.first { $0.id == id }
    }

    /// 위젯이 표시할 대표 디데이 (고정된 것이 없으면 가장 임박한 순)
    var pinnedOrFirst: DDayItem? {
        if let pinned = item(with: pinnedID) { return pinned }
        return sortedByUpcoming.first
    }

    /// 남은 일수 기준 정렬 (지난 것은 뒤로)
    var sortedByUpcoming: [DDayItem] {
        items.sorted { a, b in
            let da = a.dayDifference()
            let db = b.dayDifference()
            // 미래(>=0)를 앞으로, 그 안에서는 가까운 순
            let aFuture = da >= 0
            let bFuture = db >= 0
            if aFuture != bFuture { return aFuture }
            if aFuture { return da < db }
            return da > db
        }
    }

    // MARK: - 영속화

    private func persist() {
        guard let defaults else { return }
        if let data = try? JSONEncoder().encode(items) {
            defaults.set(data, forKey: AppGroup.storageKey)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func load() {
        guard let defaults,
              let data = defaults.data(forKey: AppGroup.storageKey),
              let decoded = try? JSONDecoder().decode([DDayItem].self, from: data) else {
            items = []
            return
        }
        items = decoded
        if let str = defaults.string(forKey: AppGroup.pinnedKey) {
            pinnedID = UUID(uuidString: str)
        }
    }

    // MARK: - 위젯 전용 읽기 (익스텐션에서 사용)

    /// 위젯 프로세스에서 저장된 디데이를 읽어옵니다.
    static func loadItemsForWidget() -> [DDayItem] {
        guard let defaults = UserDefaults(suiteName: AppGroup.identifier),
              let data = defaults.data(forKey: AppGroup.storageKey),
              let decoded = try? JSONDecoder().decode([DDayItem].self, from: data) else {
            return []
        }
        return decoded
    }

    static func loadPinnedIDForWidget() -> UUID? {
        guard let defaults = UserDefaults(suiteName: AppGroup.identifier),
              let str = defaults.string(forKey: AppGroup.pinnedKey) else { return nil }
        return UUID(uuidString: str)
    }
}
