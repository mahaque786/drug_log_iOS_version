//
//  DoseLoggerView.swift
//  DrugLog
//
//  Form for logging medication doses with safety warning checks
//  and recent dose history.
//

import SwiftUI

struct DoseLoggerView: View {
    @EnvironmentObject var medicationStore: MedicationStore
    @EnvironmentObject var logStore: DrugLogStore

    @State private var selectedMedicationName: String = ""
    @State private var selectedDose: Double = 0
    @State private var unitsTaken: Int = 1
    @State private var selectedReason: String = ""
    @State private var warnings: [SafetyWarning] = []
    @State private var showWarnings: Bool = false
    @State private var showSuccess: Bool = false
    @State private var statusMessage: String = ""

    var selectedMedication: Medication? {
        medicationStore.medication(named: selectedMedicationName)
    }

    var totalDose: Double {
        selectedDose * Double(unitsTaken)
    }

    var body: some View {
        NavigationView {
            Form {
                // MARK: - Dose entry form
                Section {
                    // Medication picker
                    Picker("Medication", selection: $selectedMedicationName) {
                        Text("Select a medication...").tag("")
                        ForEach(medicationStore.medications) { med in
                            Text(med.genericName).tag(med.genericName)
                        }
                    }
                    .onChange(of: selectedMedicationName) { _ in
                        resetFormForNewMedication()
                    }

                    if let med = selectedMedication {
                        // Dose picker
                        Picker("Dose", selection: $selectedDose) {
                            Text("Select a dose...").tag(0.0)
                            ForEach(med.doses, id: \.self) { dose in
                                Text(med.formatDose(dose)).tag(dose)
                            }
                        }

                        // Units stepper
                        Stepper("Units taken: \(unitsTaken)", value: $unitsTaken, in: 1...20)

                        // Total dose display
                        if selectedDose > 0 {
                            HStack {
                                Text("Total dose")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(med.formatDose(totalDose))
                                    .fontWeight(.semibold)
                            }
                        }

                        // Reason picker
                        Picker("Reason", selection: $selectedReason) {
                            Text("Select reason...").tag("")
                            ForEach(med.indication.onLabel, id: \.self) { reason in
                                Text("On-label: \(reason)").tag(reason)
                            }
                            ForEach(med.indication.offLabel, id: \.self) { reason in
                                Text("Off-label: \(reason)").tag(reason)
                            }
                        }
                    }
                } header: {
                    Text("Log a Medication Dose")
                }

                // Submit button
                if selectedMedication != nil {
                    Section {
                        Button(action: { evaluateAndSubmit() }) {
                            HStack {
                                Spacer()
                                Text("Log Dose")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .disabled(
                            selectedMedicationName.isEmpty
                                || selectedDose <= 0
                                || selectedReason.isEmpty
                        )
                    }
                }

                // MARK: - Safety warnings
                if showWarnings && !warnings.isEmpty {
                    Section {
                        ForEach(warnings) { warning in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(warning.message)
                                    .font(.caption)
                            }
                            .padding(.vertical, 4)
                        }

                        Button(action: { confirmLog() }) {
                            HStack {
                                Spacer()
                                Text("Proceed Anyway")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .background(Color.red)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    } header: {
                        Label("Safety Warnings", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }
                }

                // MARK: - Success message
                if showSuccess {
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Dose logged successfully.")
                                .foregroundColor(Color(red: 0.09, green: 0.39, blue: 0.20))
                        }
                        .padding(.vertical, 4)
                    }
                }

                // MARK: - Sync status
                if let error = logStore.lastSyncError {
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.icloud")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } header: {
                        Text("Sync Status")
                    }
                }

                // MARK: - Recent logs
                Section {
                    if logStore.recentLogs.isEmpty {
                        Text("No logged doses yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(logStore.recentLogs) { log in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(log.medicationName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(formatDose(log))
                                        .font(.subheadline)
                                }
                                HStack {
                                    Text(log.reason)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(formatTimestamp(log.timestamp))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                } header: {
                    Text("Recent Logs")
                }
            }
            .navigationTitle("Dose Logger")
            .onAppear {
                logStore.fetchFromAppsScript()
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Actions

    private func resetFormForNewMedication() {
        showWarnings = false
        showSuccess = false
        warnings = []
        unitsTaken = 1
        if let med = selectedMedication {
            selectedDose = med.doses.first ?? 0
            selectedReason = med.indication.onLabel.first ?? med.indication.offLabel.first ?? ""
        } else {
            selectedDose = 0
            selectedReason = ""
        }
    }

    private func evaluateAndSubmit() {
        guard let med = selectedMedication else { return }
        showSuccess = false

        let checker = SafetyChecker(
            medicationStore: medicationStore,
            logStore: logStore
        )
        warnings = checker.evaluate(medication: med, doseAmount: totalDose)

        if warnings.isEmpty {
            confirmLog()
        } else {
            showWarnings = true
        }
    }

    private func confirmLog() {
        guard let med = selectedMedication else { return }
        let log = DoseLog(
            medicationName: med.genericName,
            dose: totalDose,
            doseUnit: med.doseUnit,
            reason: selectedReason
        )
        logStore.addLog(log)

        showWarnings = false
        warnings = []
        showSuccess = true

        // Reset form
        selectedMedicationName = ""
        selectedDose = 0
        unitsTaken = 1
        selectedReason = ""
    }

    // MARK: - Formatting helpers

    private func formatDose(_ log: DoseLog) -> String {
        let doseStr = log.dose.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", log.dose)
            : String(log.dose)
        return "\(doseStr) \(log.doseUnit)"
    }

    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
