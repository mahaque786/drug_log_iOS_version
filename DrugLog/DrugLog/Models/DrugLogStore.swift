//
//  DrugLogStore.swift
//  DrugLog
//
//  Data store for managing dose log entries with local persistence
//  and Google Apps Script synchronization.
//

import Foundation
import os.log

class DrugLogStore: ObservableObject {
    @Published var logs: [DoseLog] = []
    @Published var isSyncing: Bool = false
    @Published var lastSyncError: String?

    private let savePath: URL
    private let appsScriptURL = "https://script.google.com/macros/s/AKfycbwNeAFxg6IpfzQf9iDxAx3spavPA0cwNvwvAEFKdBEgt4OmndJREHGT10TOVUVFt4Nsbg/exec"

    init() {
        savePath = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("doselog.json")
        loadLocal()
    }

    // MARK: - Public API

    func addLog(_ log: DoseLog) {
        logs.insert(log, at: 0)
        saveLocal()
        postToAppsScript(log)
    }

    var recentLogs: [DoseLog] {
        Array(logs.prefix(20))
    }

    func logsInLast24Hours(for medicationName: String) -> [DoseLog] {
        let cutoff = Date().addingTimeInterval(-24 * 3600)
        let normalizedName = medicationName.lowercased()
        return logs.filter {
            $0.medicationName.lowercased() == normalizedName && $0.timestamp > cutoff
        }
    }

    func lastLog(for medicationName: String) -> DoseLog? {
        let normalizedName = medicationName.lowercased()
        return logs.first { $0.medicationName.lowercased() == normalizedName }
    }

    func medicationsLoggedInLast24Hours() -> Set<String> {
        let cutoff = Date().addingTimeInterval(-24 * 3600)
        return Set(
            logs.filter { $0.timestamp > cutoff }
                .map { $0.medicationName.lowercased() }
        )
    }

    // MARK: - Local persistence

    private func saveLocal() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(logs)
            try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
        } catch {
            os_log("Failed to save dose log: %{public}@", type: .error, error.localizedDescription)
        }
    }

    private func loadLocal() {
        do {
            let data = try Data(contentsOf: savePath)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            logs = try decoder.decode([DoseLog].self, from: data)
        } catch {
            logs = []
        }
    }

    // MARK: - Google Apps Script sync

    func fetchFromAppsScript() {
        guard let url = URL(string: appsScriptURL + "?action=logs") else { return }
        isSyncing = true

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isSyncing = false
                if let error = error {
                    self?.lastSyncError = error.localizedDescription
                    return
                }
                guard let data = data else { return }
                do {
                    let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    guard let success = response?["success"] as? Bool, success,
                          let remoteLogs = response?["logs"] as? [[String: Any]]
                    else {
                        self?.lastSyncError = "Invalid response from server"
                        return
                    }

                    let formatter = ISO8601DateFormatter()
                    var newLogs: [DoseLog] = []
                    for entry in remoteLogs {
                        guard let tsString = entry["timestamp"] as? String,
                              let ts = formatter.date(from: tsString)
                                  ?? Self.parseFallbackDate(tsString),
                              let name = entry["medicationName"] as? String,
                              let reason = entry["reason"] as? String
                        else { continue }
                        let dose = (entry["dose"] as? Double)
                            ?? Double(entry["dose"] as? String ?? "") ?? 0
                        newLogs.append(DoseLog(
                            timestamp: ts,
                            medicationName: name,
                            dose: dose,
                            doseUnit: "mg",
                            reason: reason
                        ))
                    }

                    if !newLogs.isEmpty {
                        self?.logs = newLogs.sorted { $0.timestamp > $1.timestamp }
                        self?.saveLocal()
                    }
                    self?.lastSyncError = nil
                } catch {
                    self?.lastSyncError = error.localizedDescription
                }
            }
        }.resume()
    }

    private func postToAppsScript(_ log: DoseLog) {
        guard let url = URL(string: appsScriptURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain;charset=utf-8", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "action": "log",
            "medicationName": log.medicationName,
            "dose": log.dose,
            "reason": log.reason,
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.lastSyncError = error.localizedDescription
                } else {
                    self?.lastSyncError = nil
                }
            }
        }.resume()
    }

    private static func parseFallbackDate(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: string)
    }
}
