//
//  DoseLog.swift
//  DrugLog
//
//  Model representing a logged medication dose entry.
//

import Foundation

struct DoseLog: Identifiable, Codable, Equatable {
    let id: UUID
    let timestamp: Date
    let medicationName: String
    let dose: Double
    let doseUnit: String
    let reason: String

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        medicationName: String,
        dose: Double,
        doseUnit: String,
        reason: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.medicationName = medicationName
        self.dose = dose
        self.doseUnit = doseUnit
        self.reason = reason
    }
}
