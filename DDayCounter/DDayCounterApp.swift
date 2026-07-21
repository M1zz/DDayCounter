//
//  DDayCounterApp.swift
//  DDayCounter
//
//  앱 진입점
//

import SwiftUI

@main
struct DDayCounterApp: App {
    @StateObject private var store = DDayStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .sheet(isPresented: Binding(
                    get: { !store.hasChosenCalendarMode },
                    set: { _ in }
                )) {
                    CalendarModeOnboardingView()
                        .environmentObject(store)
                }
        }
    }
}
