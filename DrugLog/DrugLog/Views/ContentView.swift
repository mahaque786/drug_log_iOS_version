//
//  ContentView.swift
//  DrugLog
//
//  Root view with tab-based navigation for dose logging, mental health
//  check-in, and medication reference.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var medicationStore = MedicationStore()
    @StateObject private var logStore = DrugLogStore()
    @StateObject private var checkinStore = MoodCheckinStore()

    var body: some View {
        TabView {
            DoseLoggerView()
                .tabItem {
                    Label("Log Dose", systemImage: "pills.fill")
                }

            MoodCheckinView()
                .tabItem {
                    Label("Check-in", systemImage: "brain.head.profile")
                }

            MedicationListView()
                .tabItem {
                    Label("Reference", systemImage: "book.fill")
                }
        }
        .environmentObject(medicationStore)
        .environmentObject(logStore)
        .environmentObject(checkinStore)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
