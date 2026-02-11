//
//  MoodCheckinStore.swift
//  DrugLog
//
//  Data store for mental health check-in entries with local
//  persistence and Google Apps Script synchronization.
//

import Foundation
import os.log

class MoodCheckinStore: ObservableObject {
    @Published var checkins: [MoodCheckin] = []
    @Published var isSyncing: Bool = false
    @Published var lastSyncError: String?

    private let savePath: URL
    private let appsScriptURL = "https://script.google.com/macros/s/AKfycbxJETVSh8FasaFJUunijx4wyYr-n5KHZo0K2fCzBwzN44S4XQltFQ6OXFdERUXwf8ib/exec"

    init() {
        savePath = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("moodcheckins.json")
        loadLocal()
    }

    // MARK: - Public API

    func addCheckin(_ checkin: MoodCheckin) {
        checkins.insert(checkin, at: 0)
        saveLocal()
        postToAppsScript(checkin)
    }

    var recentCheckins: [MoodCheckin] {
        Array(checkins.prefix(30))
    }

    /// Returns the check-in for a specific date string (yyyy-MM-dd), if any.
    func checkin(for date: String) -> MoodCheckin? {
        checkins.first { $0.date == date }
    }

    // MARK: - Local persistence

    private func saveLocal() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(checkins)
            try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
        } catch {
            os_log("Failed to save mood checkins: %{public}@", type: .error, error.localizedDescription)
        }
    }

    private func loadLocal() {
        do {
            let data = try Data(contentsOf: savePath)
            let decoder = JSONDecoder()
            checkins = try decoder.decode([MoodCheckin].self, from: data)
        } catch {
            checkins = []
        }
    }

    // MARK: - Google Apps Script sync

    private func postToAppsScript(_ checkin: MoodCheckin) {
        guard let url = URL(string: appsScriptURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "date": checkin.date,
            "a1_depressed": checkin.a1Depressed,
            "a2_interest": checkin.a2Interest,
            "a3_anxious": checkin.a3Anxious,
            "a4_worry": checkin.a4Worry,
            "b5_focus": checkin.b5Focus,
            "b6_task_start": checkin.b6TaskStart,
            "b7_function": checkin.b7Function,
            "c8_sleep_hrs": checkin.c8SleepHrs,
            "c9_sleep_qual": checkin.c9SleepQual,
            "c10_energy": checkin.c10Energy,
            "d11_wired": checkin.d11Wired,
            "d12_less_sleep": checkin.d12LessSleep,
            "d_asrm_total": checkin.dAsrmTotal as Any,
            "e13_se_freq": checkin.e13SeFreq,
            "e14_se_intensity": checkin.e14SeIntensity,
            "e15_se_burden": checkin.e15SeBurden,
            "f16_safety": checkin.f16Safety,
            "notes": checkin.notes,
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        isSyncing = true
        URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
            DispatchQueue.main.async {
                self?.isSyncing = false
                if let error = error {
                    self?.lastSyncError = error.localizedDescription
                } else {
                    self?.lastSyncError = nil
                }
            }
        }.resume()
    }
}
