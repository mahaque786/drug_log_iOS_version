//
//  DrugEntry.swift
//  DrugLog
//
//  Model representing a medication entry in the log.
//

import Foundation

struct DrugEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var dosage: String
    var frequency: String
    var notes: String?
    var createdAt: Date
    var lastTaken: Date?
    
    init(id: UUID = UUID(), name: String, dosage: String, frequency: String, notes: String? = nil, createdAt: Date = Date(), lastTaken: Date? = nil) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.notes = notes
        self.createdAt = createdAt
        self.lastTaken = lastTaken
    }
}

extension DrugEntry {
    static var example: DrugEntry {
        DrugEntry(
            name: "Aspirin",
            dosage: "100mg",
            frequency: "Once daily",
            notes: "Take with food"
        )
    }
}
