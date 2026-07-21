//
//  DDayEditorView.swift
//  DDayCounter
//
//  디데이 추가 / 편집 화면
//

import SwiftUI

struct DDayEditorView: View {
    @EnvironmentObject var store: DDayStore
    @Environment(\.dismiss) private var dismiss

    /// nil 이면 새로 추가, 값이 있으면 편집
    let item: DDayItem?

    @State private var title: String
    @State private var date: Date
    @State private var style: DDayCountStyle
    @State private var colorHex: String
    @State private var symbol: String
    @State private var repeatsYearly: Bool
    @State private var pinToWidget: Bool

    init(item: DDayItem?) {
        self.item = item
        _title = State(initialValue: item?.title ?? "")
        _date = State(initialValue: item?.date ?? Date())
        _style = State(initialValue: item?.style ?? .dday)
        _colorHex = State(initialValue: item?.colorHex ?? DDayPalette.colors[0])
        _symbol = State(initialValue: item?.symbol ?? DDayPalette.symbols[0])
        _repeatsYearly = State(initialValue: item?.repeatsYearly ?? false)
        _pinToWidget = State(initialValue: false)
    }

    private var isEditing: Bool { item != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("정보") {
                    TextField("제목 (예: 수능, 우리 기념일)", text: $title)
                    DatePicker("날짜", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                    Toggle("매년 반복 (생일·기념일)", isOn: $repeatsYearly)
                }

                Section("카운트 방식") {
                    Picker("방식", selection: $style) {
                        ForEach(DDayCountStyle.allCases) { s in
                            Text(s.title).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(previewText)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: colorHex) ?? .accentColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                }

                Section("아이콘") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(DDayPalette.symbols, id: \.self) { s in
                                Text(s)
                                    .font(.system(size: 26))
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle().fill(symbol == s
                                                      ? (Color(hex: colorHex) ?? .accentColor).opacity(0.2)
                                                      : Color.gray.opacity(0.1))
                                    )
                                    .overlay(
                                        Circle().stroke(symbol == s
                                                        ? (Color(hex: colorHex) ?? .accentColor)
                                                        : .clear, lineWidth: 2)
                                    )
                                    .onTapGesture { symbol = s }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("색상") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(DDayPalette.colors, id: \.self) { hex in
                                Circle()
                                    .fill(Color(hex: hex) ?? .accentColor)
                                    .frame(width: 34, height: 34)
                                    .overlay(
                                        Circle().stroke(.primary, lineWidth: colorHex == hex ? 3 : 0)
                                            .padding(2)
                                    )
                                    .onTapGesture { colorHex = hex }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section {
                    Toggle("위젯에 이 디데이 고정", isOn: $pinToWidget)
                } footer: {
                    Text("켜면 홈·잠금 화면 위젯의 기본 표시가 이 디데이로 설정됩니다.")
                }

                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            if let item { store.delete(item) }
                            dismiss()
                        } label: {
                            Label("삭제", systemImage: "trash")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "디데이 편집" : "디데이 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private var previewText: String {
        let temp = DDayItem(title: title, date: date, style: style,
                            colorHex: colorHex, symbol: symbol, repeatsYearly: repeatsYearly)
        return temp.countText()
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if let existing = item {
            var updated = existing
            updated.title = trimmed
            updated.date = date
            updated.style = style
            updated.colorHex = colorHex
            updated.symbol = symbol
            updated.repeatsYearly = repeatsYearly
            store.update(updated)
            if pinToWidget { store.pinnedID = updated.id }
        } else {
            let newItem = DDayItem(title: trimmed, date: date, style: style,
                                   colorHex: colorHex, symbol: symbol, repeatsYearly: repeatsYearly)
            store.add(newItem)
            if pinToWidget { store.pinnedID = newItem.id }
        }
        dismiss()
    }
}

#Preview {
    DDayEditorView(item: nil).environmentObject(DDayStore.shared)
}
