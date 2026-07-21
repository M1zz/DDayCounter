//
//  CalendarModeOnboardingView.swift
//  DDayCounter
//
//  앱 최초 실행 시 양력/음력 기본 달력을 선택하는 온보딩 화면
//

import SwiftUI

struct CalendarModeOnboardingView: View {
    @EnvironmentObject var store: DDayStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Text("🌙")
                    .font(.system(size: 64))
                Text("음력세기")
                    .font(.largeTitle.bold())
                Text("어떤 달력을 기본으로 사용할까요?")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text("디데이를 추가할 때 기본으로 적용됩니다.\n각 디데이마다 나중에 바꿀 수 있어요.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    choose(.solar)
                } label: {
                    modeLabel(title: "양력", subtitle: "일반 달력 (그레고리력)")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    choose(.lunar)
                } label: {
                    modeLabel(title: "음력", subtitle: "설·추석·음력 생일 등")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .interactiveDismissDisabled(true)
    }

    private func modeLabel(title: String, subtitle: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.title3.bold())
            Text(subtitle)
                .font(.caption)
                .opacity(0.85)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func choose(_ mode: CalendarMode) {
        store.calendarMode = mode
        store.hasChosenCalendarMode = true
        dismiss()
    }
}

#Preview {
    CalendarModeOnboardingView().environmentObject(DDayStore.shared)
}
