//
//  MedicationStore.swift
//  DrugLog
//
//  Loads and provides access to the bundled medlist.json medication reference data.
//

import Foundation
import os.log

class MedicationStore: ObservableObject {
    @Published var medications: [Medication] = []
    @Published var source: String = ""
    @Published var disclaimer: String = ""
    @Published var dateCompiled: String = ""

    init() {
        loadFromBundle()
    }

    private func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "medlist", withExtension: "json") else {
            os_log("medlist.json not found in bundle", type: .error)
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(MedicationData.self, from: data)
            medications = decoded.medications
            source = decoded.source
            disclaimer = decoded.disclaimer
            dateCompiled = decoded.dateCompiled
        } catch {
            os_log("Failed to decode medlist.json: %{public}@", type: .error, error.localizedDescription)
        }
    }

    func medication(named name: String) -> Medication? {
        medications.first { $0.genericName == name }
    }

    func search(_ query: String) -> [Medication] {
        guard !query.isEmpty else { return medications }
        let q = query.lowercased()
        return medications.filter { med in
            med.genericName.lowercased().contains(q)
                || med.brandNames.contains(where: { $0.lowercased().contains(q) })
                || med.indication.onLabel.contains(where: { $0.lowercased().contains(q) })
                || med.indication.offLabel.contains(where: { $0.lowercased().contains(q) })
                || med.mechanismOfAction.lowercased().contains(q)
                || med.maximumDailyDosage.lowercased().contains(q)
                || med.halfLife.lowercased().contains(q)
                || med.activeMetabolites.lowercased().contains(q)
        }
    }
}
