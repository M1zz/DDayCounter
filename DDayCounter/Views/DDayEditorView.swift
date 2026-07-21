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
    @State private var isLunar: Bool
    @State private var pinToWidget: Bool

    // 음력 직접 선택용 상태 (양력 date와 동기화됨)
    @State private var lunarYear: Int
    @State private var lunarMonth: Int
    @State private var lunarDay: Int
    @State private var lunarIsLeap: Bool

    init(item: DDayItem?) {
        self.item = item
        let initialDate = item?.date ?? Date()
        _title = State(initialValue: item?.title ?? "")
        _date = State(initialValue: initialDate)
        _style = State(initialValue: item?.style ?? .dday)
        _colorHex = State(initialValue: item?.colorHex ?? DDayPalette.colors[0])
        _symbol = State(initialValue: item?.symbol ?? DDayPalette.symbols[0])
        _repeatsYearly = State(initialValue: item?.repeatsYearly ?? false)
        // 편집이면 기존 값, 새로 추가면 전역 달력 모드를 기본값으로 사용
        _isLunar = State(initialValue: item?.isLunar ?? DDayStore.shared.calendarMode.isLunar)
        _pinToWidget = State(initialValue: false)

        // 음력 선택 상태를 date로부터 초기화
        let lunar = KoreanLunar.components(from: initialDate)
        _lunarYear = State(initialValue: Calendar.current.component(.year, from: initialDate))
        _lunarMonth = State(initialValue: lunar.month == 0 ? 1 : lunar.month)
        _lunarDay = State(initialValue: lunar.day == 0 ? 1 : lunar.day)
        _lunarIsLeap = State(initialValue: lunar.isLeap)
    }

    /// 음력 연도 선택 범위
    private var lunarYearRange: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        return Array((current - 100)...(current + 30))
    }

    private var isEditing: Bool { item != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("제목 (예: 수능, 우리 기념일)", text: $title)
                    Picker("달력", selection: $isLunar) {
                        Text("양력").tag(false)
                        Text("음력").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: isLunar) { _, nowLunar in
                        if nowLunar { syncLunarStateFromDate() }
                    }

                    if isLunar {
                        lunarDatePickers
                    } else {
                        DatePicker("날짜", selection: $date, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "ko_KR"))
                    }

                    Toggle("매년 반복 (생일·기념일)", isOn: $repeatsYearly)
                } header: {
                    Text("정보")
                } footer: {
                    if isLunar {
                        Text("음력 날짜로 저장돼요.\n매년 반복을 켜면 매해 같은 음력 날짜에 맞춰\n자동으로 계산돼요. (양력 날짜는 매년 달라져요)")
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(3)
                    }
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

    // MARK: - 음력 날짜 선택 UI

    @ViewBuilder
    private var lunarDatePickers: some View {
        Picker("음력 연도", selection: $lunarYear) {
            ForEach(lunarYearRange, id: \.self) { y in
                Text("\(String(y))년").tag(y)
            }
        }
        .onChange(of: lunarYear) { _, _ in recomputeDateFromLunar() }

        Picker("음력 월", selection: $lunarMonth) {
            ForEach(1...12, id: \.self) { m in
                Text("\(m)월").tag(m)
            }
        }
        .onChange(of: lunarMonth) { _, _ in
            // 월이 바뀌면 윤달 존재 여부를 다시 확인
            if lunarIsLeap && !KoreanLunar.leapMonthExists(month: lunarMonth, gregorianYear: lunarYear) {
                lunarIsLeap = false
            }
            recomputeDateFromLunar()
        }

        Picker("음력 일", selection: $lunarDay) {
            ForEach(1...30, id: \.self) { d in
                Text("\(d)일").tag(d)
            }
        }
        .onChange(of: lunarDay) { _, _ in recomputeDateFromLunar() }

        if KoreanLunar.leapMonthExists(month: lunarMonth, gregorianYear: lunarYear) {
            Toggle("윤달", isOn: $lunarIsLeap)
                .onChange(of: lunarIsLeap) { _, _ in recomputeDateFromLunar() }
        }

        HStack {
            Text("양력")
                .foregroundStyle(.secondary)
            Spacer()
            Text(solarDateString)
                .foregroundStyle(Color(hex: colorHex) ?? .accentColor)
        }
        .font(.subheadline)
    }

    private var solarDateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일 (E)"
        return f.string(from: date)
    }

    /// 음력 선택값 → 양력 date 로 변환하여 저장
    private func recomputeDateFromLunar() {
        if let d = KoreanLunar.occurrence(month: lunarMonth, day: lunarDay,
                                          isLeap: lunarIsLeap, inGregorianYear: lunarYear) {
            date = d
        }
    }

    /// 현재 date(양력) → 음력 선택 상태로 동기화 (양력→음력 전환 시)
    private func syncLunarStateFromDate() {
        let lunar = KoreanLunar.components(from: date)
        lunarYear = Calendar.current.component(.year, from: date)
        lunarMonth = lunar.month == 0 ? 1 : lunar.month
        lunarDay = lunar.day == 0 ? 1 : lunar.day
        lunarIsLeap = lunar.isLeap
    }

    private var previewText: String {
        let temp = DDayItem(title: title, date: date, style: style,
                            colorHex: colorHex, symbol: symbol,
                            repeatsYearly: repeatsYearly, isLunar: isLunar)
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
            updated.isLunar = isLunar
            store.update(updated)
            if pinToWidget { store.pinnedID = updated.id }
        } else {
            let newItem = DDayItem(title: trimmed, date: date, style: style,
                                   colorHex: colorHex, symbol: symbol,
                                   repeatsYearly: repeatsYearly, isLunar: isLunar)
            store.add(newItem)
            if pinToWidget { store.pinnedID = newItem.id }
        }
        dismiss()
    }
}

#Preview {
    DDayEditorView(item: nil).environmentObject(DDayStore.shared)
}
