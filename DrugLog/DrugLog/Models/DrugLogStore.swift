//
//  DrugLogStore.swift
//  DrugLog
//
//  Data store for managing drug entries.
//

import Foundation
import os.log

class DrugLogStore: ObservableObject {
    @Published var entries: [DrugEntry] = []
    
    private let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("druglog.json")
    
    init() {
        load()
    }
    
    func add(_ entry: DrugEntry) {
        entries.append(entry)
        save()
    }
    
    func update(_ entry: DrugEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            save()
        }
    }
    
    func delete(_ entry: DrugEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }
    
    func markAsTaken(_ entry: DrugEntry) {
        var updatedEntry = entry
        updatedEntry.lastTaken = Date()
        update(updatedEntry)
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
        } catch {
            os_log("Failed to save drug log: %{public}@", log: .default, type: .error, error.localizedDescription)
        }
    }
    
    private func load() {
        do {
            let data = try Data(contentsOf: savePath)
            entries = try JSONDecoder().decode([DrugEntry].self, from: data)
        } catch {
            // No saved data yet, start with empty array
            entries = []
        }
    }
}
