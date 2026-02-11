//
//  SafetyChecker.swift
//  DrugLog
//
//  Evaluates safety warnings before logging a medication dose.
//  Checks: timing between doses, max daily dosage, drug interactions,
//  and colestipol absorption interference.
//

import Foundation

struct SafetyWarning: Identifiable {
    let id = UUID()
    let message: String
}

struct SafetyChecker {
    let medicationStore: MedicationStore
    let logStore: DrugLogStore

    private static let concerningKeywords = [
        "serotonin syndrome", "seizure", "hypertension", "tachycardia",
        "qt", "arrhythmia", "cardiac", "respiratory", "toxicity",
        "pressor", "contraindicated", "cns overstimulation",
    ]

    func evaluate(medication: Medication, doseAmount: Double) -> [SafetyWarning] {
        var warnings: [SafetyWarning] = []

        if let w = checkTooSoon(medication: medication) {
            warnings.append(w)
        }
        if let w = checkMaxDaily(medication: medication, newDose: doseAmount) {
            warnings.append(w)
        }
        warnings.append(contentsOf: checkInteractions(medication: medication))
        if let w = checkColestipol(medication: medication) {
            warnings.append(w)
        }

        return warnings
    }

    // MARK: - Individual checks

    private func checkTooSoon(medication: Medication) -> SafetyWarning? {
        guard let minHours = medication.minimumHoursBetweenDoses,
              let lastLog = logStore.lastLog(for: medication.genericName)
        else { return nil }

        let hoursSinceLast = Date().timeIntervalSince(lastLog.timestamp) / 3600
        if hoursSinceLast < minHours {
            return SafetyWarning(
                message: "Too soon since last dose of \(medication.genericName). "
                    + "Wait at least \(String(format: "%.0f", minHours)) hours between doses."
            )
        }
        return nil
    }

    private func checkMaxDaily(medication: Medication, newDose: Double) -> SafetyWarning? {
        guard let maxDaily = medication.maxDailyDoseNumeric else { return nil }

        let logsLast24h = logStore.logsInLast24Hours(for: medication.genericName)
        let totalLast24h = logsLast24h.reduce(0.0) { $0 + $1.dose }

        if totalLast24h + newDose > maxDaily {
            return SafetyWarning(
                message: "This dose may exceed the maximum daily dose for "
                    + "\(medication.genericName) (\(medication.maximumDailyDosage))."
            )
        }
        return nil
    }

    private func checkInteractions(medication: Medication) -> [SafetyWarning] {
        let recentMeds = logStore.medicationsLoggedInLast24Hours()
        var warnings: [SafetyWarning] = []

        for interaction in medication.interactionsWithOtherDrugsOnThisList {
            let interactionDrugLower = interaction.drug.lowercased()

            let wasTaken = recentMeds.contains { recentMed in
                interactionDrugLower.contains(recentMed) || recentMed.contains(interactionDrugLower)
            }

            if wasTaken {
                let interactionLower = interaction.interaction.lowercased()
                let isConcerning = Self.concerningKeywords.contains { interactionLower.contains($0) }
                if isConcerning {
                    warnings.append(SafetyWarning(
                        message: "Potential concerning interaction with \(interaction.drug): "
                            + interaction.interaction
                    ))
                }
            }
        }

        return warnings
    }

    private func checkColestipol(medication: Medication) -> SafetyWarning? {
        guard !medication.genericName.lowercased().contains("colestipol") else { return nil }

        // Check all medications that contain "colestipol" in the name
        let cutoff = Date().addingTimeInterval(-4 * 3600)
        let colestipolRecent = logStore.logs.contains { log in
            log.medicationName.lowercased().contains("colestipol") && log.timestamp > cutoff
        }

        if colestipolRecent {
            return SafetyWarning(
                message: "Colestipol was taken less than 4 hours ago. "
                    + "This may reduce absorption of other medications."
            )
        }
        return nil
    }
}
