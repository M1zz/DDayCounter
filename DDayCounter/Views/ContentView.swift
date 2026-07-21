//
//  ContentView.swift
//  DDayCounter
//
//  디데이 목록 메인 화면
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: DDayStore
    @State private var showingEditor = false
    @State private var editingItem: DDayItem?

    var body: some View {
        NavigationStack {
            Group {
                if store.items.isEmpty {
                    EmptyStateView { showingEditor = true }
                } else {
                    listContent
                }
            }
            .navigationTitle("디데이")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingItem = nil
                        showingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("디데이 추가")
                }
            }
            .sheet(isPresented: $showingEditor) {
                DDayEditorView(item: editingItem)
                    .environmentObject(store)
            }
        }
    }

    private var listContent: some View {
        List {
            Section {
                ForEach(store.sortedByUpcoming) { item in
                    Button {
                        editingItem = item
                        showingEditor = true
                    } label: {
                        DDayRow(item: item, isPinned: store.pinnedID == item.id)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .swipeActions(edge: .leading) {
                        Button {
                            store.pinnedID = item.id
                        } label: {
                            Label("위젯 고정", systemImage: "pin.fill")
                        }
                        .tint(.orange)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.delete(item)
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
            } footer: {
                Text("행을 왼쪽으로 밀어 위젯에 고정할 디데이를 선택할 수 있어요. 📌 표시가 위젯에 나타납니다.")
                    .font(.caption)
            }
        }
        .listStyle(.insetGrouped)
    }
}

/// 목록의 한 행
struct DDayRow: View {
    let item: DDayItem
    let isPinned: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(item.color.opacity(0.15))
                    .frame(width: 52, height: 52)
                Text(item.symbol)
                    .font(.system(size: 26))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
                if let lunar = item.lunarText() {
                    Text(lunar)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(item.solarDateText())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(item.solarDateText())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(item.countText())
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(item.color)
        }
        .padding(.vertical, 4)
    }
}

/// 비어 있을 때 표시
struct EmptyStateView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("아직 등록된 디데이가 없어요")
                .font(.title3.bold())
            Text("중요한 날짜를 추가하고\n홈 화면과 잠금 화면 위젯으로 확인해보세요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(action: onAdd) {
                Label("디데이 추가하기", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 6)
        }
        .padding()
    }
}

#Preview {
    let store = DDayStore.shared
    DDayItem.samples.forEach { item in
        if !store.items.contains(where: { $0.id == item.id }) { store.items.append(item) }
    }
    return ContentView().environmentObject(store)
}
