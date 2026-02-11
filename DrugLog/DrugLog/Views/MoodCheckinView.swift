//
//  MoodCheckinView.swift
//  DrugLog
//
//  SwiftUI form for the daily mental health check-in,
//  covering PHQ-4, executive function, sleep, mania screening,
//  medication side effects, and safety.
//

import SwiftUI

struct MoodCheckinView: View {
    @EnvironmentObject var checkinStore: MoodCheckinStore

    // Form state
    @State private var date = Date()
    @State private var a1Depressed: Int?
    @State private var a2Interest: Int?
    @State private var a3Anxious: Int?
    @State private var a4Worry: Int?
    @State private var b5Focus: Double = 5
    @State private var b6TaskStart: Double = 5
    @State private var b7Function: Double = 5
    @State private var c8SleepHrs: String = ""
    @State private var c9SleepQual: Double = 5
    @State private var c10Energy: Double = 5
    @State private var d11Wired: Double = 0
    @State private var d12LessSleep: Double = 0
    @State private var dAsrmTotal: String = ""
    @State private var e13SeFreq: Double = 0
    @State private var e14SeIntensity: Double = 0
    @State private var e15SeBurden: Double = 0
    @State private var f16Safety: Int?
    @State private var notes: String = ""

    @State private var showSuccess: Bool = false
    @State private var showSafetyAlert: Bool = false

    private var isFormValid: Bool {
        a1Depressed != nil
            && a2Interest != nil
            && a3Anxious != nil
            && a4Worry != nil
            && f16Safety != nil
            && !c8SleepHrs.isEmpty
            && Double(c8SleepHrs) != nil
    }

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationView {
            Form {
                // Date
                Section {
                    DatePicker(
                        "Date",
                        selection: $date,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                }

                // Section A: Mood & Anxiety (PHQ-4)
                sectionA

                // Section B: Focus & Function
                sectionB

                // Section C: Sleep & Energy
                sectionC

                // Section D: Elevated Mood (ASRM)
                sectionD

                // Section E: Side Effects
                sectionE

                // Section F: Safety
                sectionF

                // Notes
                Section {
                    TextField("Triggers, observations, medication changes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes & Triggers")
                }

                // Submit
                Section {
                    Button(action: submitCheckin) {
                        HStack {
                            Spacer()
                            Text("Submit Daily Check-in")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isFormValid)
                }

                // Success
                if showSuccess {
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Check-in submitted successfully.")
                                .foregroundColor(Color(red: 0.09, green: 0.39, blue: 0.20))
                        }
                    }
                }

                // Sync status
                if let error = checkinStore.lastSyncError {
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

                // Recent check-ins
                recentCheckins
            }
            .navigationTitle("Mental Health Check-in")
        }
        .navigationViewStyle(.stack)
        .alert("Safety Notice", isPresented: $showSafetyAlert) {
            Button("I Understand", role: .cancel) { }
        } message: {
            Text("If you're experiencing thoughts of self-harm, please contact a mental health professional or crisis hotline immediately.\n\nUS: 988 Suicide & Crisis Lifeline")
        }
    }

    // MARK: - Section A: Mood & Anxiety

    private var sectionA: some View {
        Section {
            Text("Over the last 2 weeks, how often have you been bothered by the following?")
                .font(.caption)
                .foregroundColor(.secondary)

            PHQ4Row(label: "A1. Feeling down, depressed, or hopeless?", selection: $a1Depressed)
            PHQ4Row(label: "A2. Little interest or pleasure in doing things?", selection: $a2Interest)
            PHQ4Row(label: "A3. Feeling nervous, anxious, or on edge?", selection: $a3Anxious)
            PHQ4Row(label: "A4. Not being able to stop or control worrying?", selection: $a4Worry)
        } header: {
            Text("Section A: Mood & Anxiety")
        } footer: {
            Text("0 = Not at all | 1 = Several days | 2 = More than half the days | 3 = Nearly every day")
                .font(.caption2)
        }
    }

    // MARK: - Section B: Focus & Function

    private var sectionB: some View {
        Section {
            Text("Rate your experience today (0 = No difficulty, 10 = Extreme difficulty)")
                .font(.caption)
                .foregroundColor(.secondary)

            SliderRow(label: "B5. Focus/concentration difficulty", value: $b5Focus, range: 0...10)
            SliderRow(label: "B6. Difficulty starting tasks", value: $b6TaskStart, range: 0...10)
            SliderRow(label: "B7. Overall functional impairment", value: $b7Function, range: 0...10)
        } header: {
            Text("Section B: Focus & Function")
        }
    }

    // MARK: - Section C: Sleep & Energy

    private var sectionC: some View {
        Section {
            HStack {
                Text("C8. Hours of sleep last night")
                Spacer()
                TextField("7.5", text: $c8SleepHrs)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
            }

            SliderRow(label: "C9. Sleep quality (0 = Terrible, 10 = Excellent)", value: $c9SleepQual, range: 0...10)
            SliderRow(label: "C10. Energy level (0 = Exhausted, 10 = Very energetic)", value: $c10Energy, range: 0...10)
        } header: {
            Text("Section C: Sleep & Energy")
        }
    }

    // MARK: - Section D: Elevated Mood (ASRM)

    private var sectionD: some View {
        Section {
            Text("Have you experienced any of the following? (0 = Not at all, 10 = Extremely)")
                .font(.caption)
                .foregroundColor(.secondary)

            SliderRow(label: "D11. Feeling wired, hyper, or overly energetic", value: $d11Wired, range: 0...10)
            SliderRow(label: "D12. Needing less sleep without feeling tired", value: $d12LessSleep, range: 0...10)

            HStack {
                Text("ASRM Total (optional)")
                    .font(.subheadline)
                Spacer()
                TextField("0-20", text: $dAsrmTotal)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
            }
        } header: {
            Text("Section D: Elevated Mood")
        }
    }

    // MARK: - Section E: Side Effects

    private var sectionE: some View {
        Section {
            Text("If taking medication, rate side effects (0 = None, 6 = Severe)")
                .font(.caption)
                .foregroundColor(.secondary)

            SliderRow(label: "E13. Frequency of side effects", value: $e13SeFreq, range: 0...6)
            SliderRow(label: "E14. Intensity/severity", value: $e14SeIntensity, range: 0...6)
            SliderRow(label: "E15. Overall burden", value: $e15SeBurden, range: 0...6)
        } header: {
            Text("Section E: Medication Side Effects")
        }
    }

    // MARK: - Section F: Safety

    private var sectionF: some View {
        Section {
            Text("Have you had thoughts of hurting yourself or others?")
                .font(.caption)
                .foregroundColor(.secondary)

            Picker("F16. Self-harm or harm thoughts", selection: Binding(
                get: { f16Safety ?? -1 },
                set: { newValue in
                    f16Safety = newValue >= 0 ? newValue : nil
                    if let val = f16Safety, val > 0 {
                        showSafetyAlert = true
                    }
                }
            )) {
                Text("Select...").tag(-1)
                Text("0 - Not at all").tag(0)
                Text("1 - A little").tag(1)
                Text("2 - Moderate").tag(2)
                Text("3 - Frequently").tag(3)
            }

            if let val = f16Safety, val > 0 {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("If you're experiencing thoughts of self-harm, please contact a mental health professional or crisis hotline. US: 988 Suicide & Crisis Lifeline")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        } header: {
            Label("Section F: Safety", systemImage: "heart.fill")
        }
    }

    // MARK: - Recent check-ins

    private var recentCheckins: some View {
        Section {
            if checkinStore.recentCheckins.isEmpty {
                Text("No check-ins recorded yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(checkinStore.recentCheckins.prefix(10)) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(entry.date)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("PHQ-4: \(entry.phq4Total)")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(phq4Color(entry.phq4Total).opacity(0.15))
                                .foregroundColor(phq4Color(entry.phq4Total))
                                .cornerRadius(4)
                        }
                        HStack(spacing: 12) {
                            Label("Sleep: \(String(format: "%.1f", entry.c8SleepHrs))h", systemImage: "bed.double")
                            Label("Energy: \(entry.c10Energy)", systemImage: "bolt")
                            if entry.f16Safety > 0 {
                                Label("Safety: \(entry.f16Safety)", systemImage: "exclamationmark.triangle")
                                    .foregroundColor(.red)
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
        } header: {
            Text("Recent Check-ins")
        }
    }

    // MARK: - Submission

    private func submitCheckin() {
        guard isFormValid,
              let sleepHrs = Double(c8SleepHrs)
        else { return }

        let asrmTotal: Int? = dAsrmTotal.isEmpty ? nil : Int(dAsrmTotal)

        let checkin = MoodCheckin(
            date: todayString,
            a1Depressed: a1Depressed ?? 0,
            a2Interest: a2Interest ?? 0,
            a3Anxious: a3Anxious ?? 0,
            a4Worry: a4Worry ?? 0,
            b5Focus: Int(b5Focus),
            b6TaskStart: Int(b6TaskStart),
            b7Function: Int(b7Function),
            c8SleepHrs: sleepHrs,
            c9SleepQual: Int(c9SleepQual),
            c10Energy: Int(c10Energy),
            d11Wired: Int(d11Wired),
            d12LessSleep: Int(d12LessSleep),
            dAsrmTotal: asrmTotal,
            e13SeFreq: Int(e13SeFreq),
            e14SeIntensity: Int(e14SeIntensity),
            e15SeBurden: Int(e15SeBurden),
            f16Safety: f16Safety ?? 0,
            notes: notes
        )

        checkinStore.addCheckin(checkin)
        showSuccess = true
        resetForm()
    }

    private func resetForm() {
        a1Depressed = nil
        a2Interest = nil
        a3Anxious = nil
        a4Worry = nil
        b5Focus = 5
        b6TaskStart = 5
        b7Function = 5
        c8SleepHrs = ""
        c9SleepQual = 5
        c10Energy = 5
        d11Wired = 0
        d12LessSleep = 0
        dAsrmTotal = ""
        e13SeFreq = 0
        e14SeIntensity = 0
        e15SeBurden = 0
        f16Safety = nil
        notes = ""
    }

    private func phq4Color(_ score: Int) -> Color {
        switch score {
        case 0...2: return .green
        case 3...5: return .yellow
        case 6...8: return .orange
        default: return .red
        }
    }
}

// MARK: - Reusable row components

/// A row for PHQ-4 style 0-3 radio selection.
struct PHQ4Row: View {
    let label: String
    @Binding var selection: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
            HStack(spacing: 0) {
                ForEach(0..<4) { value in
                    Button {
                        selection = value
                    } label: {
                        Text("\(value)")
                            .font(.subheadline)
                            .fontWeight(selection == value ? .bold : .regular)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(selection == value ? Color.accentColor : Color(.systemGray5))
                            .foregroundColor(selection == value ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}

/// A labeled slider row showing the current integer value.
struct SliderRow: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            }
            Slider(value: $value, in: range, step: 1)
        }
        .padding(.vertical, 4)
    }
}
