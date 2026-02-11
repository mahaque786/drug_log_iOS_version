//
//  MoodCheckin.swift
//  DrugLog
//
//  Model representing a daily mental health check-in entry,
//  based on the PHQ-4, ASRM, and related clinical scales.
//

import Foundation

struct MoodCheckin: Identifiable, Codable, Equatable {
    let id: UUID
    let date: String // yyyy-MM-dd

    // Section A: Mood & Anxiety (PHQ-4, 0-3 scale)
    let a1Depressed: Int
    let a2Interest: Int
    let a3Anxious: Int
    let a4Worry: Int

    // Section B: Focus & Function (0-10 scale)
    let b5Focus: Int
    let b6TaskStart: Int
    let b7Function: Int

    // Section C: Sleep & Energy
    let c8SleepHrs: Double
    let c9SleepQual: Int   // 0-10
    let c10Energy: Int     // 0-10

    // Section D: Elevated Mood / ASRM (0-10 scale)
    let d11Wired: Int
    let d12LessSleep: Int
    let dAsrmTotal: Int?   // Optional clinician field (0-20)

    // Section E: Medication Side Effects (0-6 scale)
    let e13SeFreq: Int
    let e14SeIntensity: Int
    let e15SeBurden: Int

    // Section F: Safety (0-3 scale)
    let f16Safety: Int

    // Notes
    let notes: String

    init(
        id: UUID = UUID(),
        date: String,
        a1Depressed: Int,
        a2Interest: Int,
        a3Anxious: Int,
        a4Worry: Int,
        b5Focus: Int,
        b6TaskStart: Int,
        b7Function: Int,
        c8SleepHrs: Double,
        c9SleepQual: Int,
        c10Energy: Int,
        d11Wired: Int,
        d12LessSleep: Int,
        dAsrmTotal: Int? = nil,
        e13SeFreq: Int,
        e14SeIntensity: Int,
        e15SeBurden: Int,
        f16Safety: Int,
        notes: String = ""
    ) {
        self.id = id
        self.date = date
        self.a1Depressed = a1Depressed
        self.a2Interest = a2Interest
        self.a3Anxious = a3Anxious
        self.a4Worry = a4Worry
        self.b5Focus = b5Focus
        self.b6TaskStart = b6TaskStart
        self.b7Function = b7Function
        self.c8SleepHrs = c8SleepHrs
        self.c9SleepQual = c9SleepQual
        self.c10Energy = c10Energy
        self.d11Wired = d11Wired
        self.d12LessSleep = d12LessSleep
        self.dAsrmTotal = dAsrmTotal
        self.e13SeFreq = e13SeFreq
        self.e14SeIntensity = e14SeIntensity
        self.e15SeBurden = e15SeBurden
        self.f16Safety = f16Safety
        self.notes = notes
    }

    // MARK: - Computed scores

    /// PHQ-2 depression subscale (A1 + A2), range 0-6
    var phq2Score: Int { a1Depressed + a2Interest }

    /// GAD-2 anxiety subscale (A3 + A4), range 0-6
    var gad2Score: Int { a3Anxious + a4Worry }

    /// PHQ-4 total (A1-A4), range 0-12
    var phq4Total: Int { phq2Score + gad2Score }

    /// Executive function average (B5-B7), range 0-10
    var executiveFunctionAverage: Double {
        Double(b5Focus + b6TaskStart + b7Function) / 3.0
    }

    /// Side effect burden average (E13-E15), range 0-6
    var sideEffectAverage: Double {
        Double(e13SeFreq + e14SeIntensity + e15SeBurden) / 3.0
    }

    enum CodingKeys: String, CodingKey {
        case id, date, notes
        case a1Depressed = "a1_depressed"
        case a2Interest = "a2_interest"
        case a3Anxious = "a3_anxious"
        case a4Worry = "a4_worry"
        case b5Focus = "b5_focus"
        case b6TaskStart = "b6_task_start"
        case b7Function = "b7_function"
        case c8SleepHrs = "c8_sleep_hrs"
        case c9SleepQual = "c9_sleep_qual"
        case c10Energy = "c10_energy"
        case d11Wired = "d11_wired"
        case d12LessSleep = "d12_less_sleep"
        case dAsrmTotal = "d_asrm_total"
        case e13SeFreq = "e13_se_freq"
        case e14SeIntensity = "e14_se_intensity"
        case e15SeBurden = "e15_se_burden"
        case f16Safety = "f16_safety"
    }
}
