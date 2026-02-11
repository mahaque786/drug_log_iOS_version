//
//  Medication.swift
//  DrugLog
//
//  Codable models matching the medlist.json medication reference schema.
//

import Foundation

// MARK: - Top-level JSON wrapper

struct MedicationData: Codable {
    let source: String
    let disclaimer: String
    let dateCompiled: String
    let medications: [Medication]

    enum CodingKeys: String, CodingKey {
        case source, disclaimer, medications
        case dateCompiled = "date_compiled"
    }
}

// MARK: - Medication

struct Medication: Codable, Identifiable {
    var id: String { genericName }

    let genericName: String
    let brandNames: [String]
    let indication: Indication
    let doses: [Double]
    let doseUnit: String
    let maximumDailyDosage: String
    let timeRequiredBetweenDoses: String
    let mechanismOfAction: String
    let timeToMaxConcentration: String
    let halfLife: String
    let activeMetabolites: String
    let halfLifeOfActiveMetabolites: String
    let interactionsWithOtherDrugsOnThisList: [DrugInteraction]
    let citations: [Citation]

    enum CodingKeys: String, CodingKey {
        case genericName = "generic_name"
        case brandNames = "brand_names"
        case indication, doses
        case doseUnit = "dose_unit"
        case maximumDailyDosage = "maximum_daily_dosage"
        case timeRequiredBetweenDoses = "time_required_between_doses"
        case mechanismOfAction = "mechanism_of_action"
        case timeToMaxConcentration = "time_to_max_concentration"
        case halfLife = "half_life"
        case activeMetabolites = "active_metabolites"
        case halfLifeOfActiveMetabolites = "half_life_of_active_metabolites"
        case interactionsWithOtherDrugsOnThisList = "interactions_with_other_drugs_on_this_list"
        case citations
    }
}

// MARK: - Nested types

struct Indication: Codable {
    let onLabel: [String]
    let offLabel: [String]

    enum CodingKeys: String, CodingKey {
        case onLabel = "on_label"
        case offLabel = "off_label"
    }
}

struct DrugInteraction: Codable, Identifiable {
    var id: String { drug }
    let drug: String
    let interaction: String
}

struct Citation: Codable, Identifiable {
    var id: String { "\(type):\(title)" }
    let type: String
    let title: String
}

// MARK: - Parsing helpers

extension Medication {
    /// Extracts the minimum number of hours from time_required_between_doses.
    /// "4-6 hours" -> 4.0, "24 hours (once daily)" -> 24.0
    var minimumHoursBetweenDoses: Double? {
        let numbers = timeRequiredBetweenDoses
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Double($0) }
        guard !numbers.isEmpty else { return nil }
        // Only return a value if the string actually mentions "hour"
        guard timeRequiredBetweenDoses.lowercased().contains("hour") else { return nil }
        return numbers.min()
    }

    /// Extracts the maximum numeric dose value from maximum_daily_dosage.
    /// "72 mg/day (adults); 54 mg/day (children)" -> 72.0
    var maxDailyDoseNumeric: Double? {
        let numbers = maximumDailyDosage
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Double($0) }
        guard !numbers.isEmpty else { return nil }
        return numbers.max()
    }

    /// All indications combined (on-label first, then off-label).
    var allIndications: [String] {
        indication.onLabel + indication.offLabel
    }

    /// Format a dose for display: "200 mg", "1 g"
    func formatDose(_ dose: Double) -> String {
        let doseStr = dose.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", dose)
            : String(dose)
        return "\(doseStr) \(doseUnit)"
    }
}
