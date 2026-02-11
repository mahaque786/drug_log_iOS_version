//
//  MedicationListView.swift
//  DrugLog
//
//  Searchable list of medications with expandable detail cards.
//

import SwiftUI

struct MedicationListView: View {
    @EnvironmentObject var medicationStore: MedicationStore
    @State private var searchText: String = ""

    var filteredMedications: [Medication] {
        medicationStore.search(searchText)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Disclaimer banner
                if !medicationStore.disclaimer.isEmpty {
                    Text(medicationStore.disclaimer)
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.57, green: 0.25, blue: 0.05))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 1.0, green: 0.95, blue: 0.78))
                }

                // Count
                HStack {
                    Spacer()
                    Text("\(filteredMedications.count) medication\(filteredMedications.count != 1 ? "s" : "")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)

                if filteredMedications.isEmpty {
                    Spacer()
                    Text("No medications match your search.")
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    List(filteredMedications) { medication in
                        MedicationCardView(medication: medication)
                    }
                    .listStyle(.plain)
                }

                // Footer
                if !medicationStore.source.isEmpty {
                    VStack(spacing: 2) {
                        Text("Source: \(medicationStore.source)")
                        Text("Compiled: \(medicationStore.dateCompiled)")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Medication Reference")
            .searchable(text: $searchText, prompt: "Search by name, brand, or keyword...")
        }
        .navigationViewStyle(.stack)
    }
}
