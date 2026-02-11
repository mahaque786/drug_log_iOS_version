//
//  ContentView.swift
//  DrugLog
//
//  Root view with tab-based navigation for dose logging and medication reference.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var medicationStore = MedicationStore()
    @StateObject private var logStore = DrugLogStore()

    var body: some View {
        TabView {
            DoseLoggerView()
                .tabItem {
                    Label("Log Dose", systemImage: "pills.fill")
                }

            MedicationListView()
                .tabItem {
                    Label("Reference", systemImage: "book.fill")
                }
        }
        .environmentObject(medicationStore)
        .environmentObject(logStore)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
