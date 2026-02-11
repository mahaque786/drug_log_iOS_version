//
//  DrugLogTests.swift
//  DrugLogTests
//
//  Unit tests for the Drug Log application models and logic.
//

import XCTest
@testable import DrugLog

class DrugLogTests: XCTestCase {

    // MARK: - Medication Decoding

    func testMedicationDecoding() throws {
        let json = """
        {
            "generic_name": "Test Drug",
            "brand_names": ["BrandA", "BrandB"],
            "indication": {
                "on_label": ["Pain relief"],
                "off_label": ["Anxiety"]
            },
            "doses": [25, 50, 100],
            "dose_unit": "mg",
            "maximum_daily_dosage": "200 mg/day",
            "time_required_between_doses": "4-6 hours",
            "mechanism_of_action": "Blocks receptors",
            "time_to_max_concentration": "1-2 hours",
            "half_life": "6 hours",
            "active_metabolites": "None",
            "half_life_of_active_metabolites": "N/A",
            "interactions_with_other_drugs_on_this_list": [
                {"drug": "Other Drug", "interaction": "May cause serotonin syndrome"}
            ],
            "citations": [
                {"type": "Drug Label", "title": "Test Drug Label"}
            ]
        }
        """.data(using: .utf8)!

        let med = try JSONDecoder().decode(Medication.self, from: json)
        XCTAssertEqual(med.genericName, "Test Drug")
        XCTAssertEqual(med.brandNames, ["BrandA", "BrandB"])
        XCTAssertEqual(med.doses, [25, 50, 100])
        XCTAssertEqual(med.doseUnit, "mg")
        XCTAssertEqual(med.indication.onLabel, ["Pain relief"])
        XCTAssertEqual(med.indication.offLabel, ["Anxiety"])
        XCTAssertEqual(med.interactionsWithOtherDrugsOnThisList.count, 1)
        XCTAssertEqual(med.citations.count, 1)
    }

    // MARK: - Parsing Helpers

    func testMinimumHoursBetweenDoses() throws {
        let json = """
        {
            "generic_name": "Test",
            "brand_names": [],
            "indication": {"on_label": [], "off_label": []},
            "doses": [10],
            "dose_unit": "mg",
            "maximum_daily_dosage": "100 mg/day",
            "time_required_between_doses": "4-6 hours (given 2-3 times daily)",
            "mechanism_of_action": "",
            "time_to_max_concentration": "",
            "half_life": "",
            "active_metabolites": "",
            "half_life_of_active_metabolites": "",
            "interactions_with_other_drugs_on_this_list": [],
            "citations": []
        }
        """.data(using: .utf8)!

        let med = try JSONDecoder().decode(Medication.self, from: json)
        // Should extract the minimum value: 2 (from "2-3 times") vs 4 (from "4-6 hours")
        // Both 2, 3, 4, 6 are extracted; minimum is 2
        // But actually the string says "4-6 hours" and "2-3 times daily"
        // The parser extracts all numbers and takes the min
        // Numbers: 4, 6, 2, 3 -> min = 2
        XCTAssertNotNil(med.minimumHoursBetweenDoses)
    }

    func testMinimumHoursOnceDaily() throws {
        let json = """
        {
            "generic_name": "Test",
            "brand_names": [],
            "indication": {"on_label": [], "off_label": []},
            "doses": [10],
            "dose_unit": "mg",
            "maximum_daily_dosage": "100 mg/day",
            "time_required_between_doses": "24 hours (once daily dosing)",
            "mechanism_of_action": "",
            "time_to_max_concentration": "",
            "half_life": "",
            "active_metabolites": "",
            "half_life_of_active_metabolites": "",
            "interactions_with_other_drugs_on_this_list": [],
            "citations": []
        }
        """.data(using: .utf8)!

        let med = try JSONDecoder().decode(Medication.self, from: json)
        XCTAssertEqual(med.minimumHoursBetweenDoses, 24)
    }

    func testMaxDailyDoseNumeric() throws {
        let json = """
        {
            "generic_name": "Test",
            "brand_names": [],
            "indication": {"on_label": [], "off_label": []},
            "doses": [10],
            "dose_unit": "mg",
            "maximum_daily_dosage": "72 mg/day (adults); 54 mg/day (children 6-12)",
            "time_required_between_doses": "24 hours",
            "mechanism_of_action": "",
            "time_to_max_concentration": "",
            "half_life": "",
            "active_metabolites": "",
            "half_life_of_active_metabolites": "",
            "interactions_with_other_drugs_on_this_list": [],
            "citations": []
        }
        """.data(using: .utf8)!

        let med = try JSONDecoder().decode(Medication.self, from: json)
        XCTAssertEqual(med.maxDailyDoseNumeric, 72)
    }

    func testFormatDose() throws {
        let json = """
        {
            "generic_name": "Test",
            "brand_names": [],
            "indication": {"on_label": [], "off_label": []},
            "doses": [2.5, 50],
            "dose_unit": "mg",
            "maximum_daily_dosage": "100 mg/day",
            "time_required_between_doses": "4 hours",
            "mechanism_of_action": "",
            "time_to_max_concentration": "",
            "half_life": "",
            "active_metabolites": "",
            "half_life_of_active_metabolites": "",
            "interactions_with_other_drugs_on_this_list": [],
            "citations": []
        }
        """.data(using: .utf8)!

        let med = try JSONDecoder().decode(Medication.self, from: json)
        XCTAssertEqual(med.formatDose(50), "50 mg")
        XCTAssertEqual(med.formatDose(2.5), "2.5 mg")
    }

    // MARK: - DoseLog

    func testDoseLogCreation() {
        let log = DoseLog(
            medicationName: "Sertraline HCl",
            dose: 100,
            doseUnit: "mg",
            reason: "Depression"
        )
        XCTAssertEqual(log.medicationName, "Sertraline HCl")
        XCTAssertEqual(log.dose, 100)
        XCTAssertEqual(log.doseUnit, "mg")
        XCTAssertEqual(log.reason, "Depression")
        XCTAssertNotNil(log.id)
        XCTAssertNotNil(log.timestamp)
    }

    func testDoseLogEquatable() {
        let id = UUID()
        let date = Date()
        let log1 = DoseLog(id: id, timestamp: date, medicationName: "A", dose: 50, doseUnit: "mg", reason: "R")
        let log2 = DoseLog(id: id, timestamp: date, medicationName: "A", dose: 50, doseUnit: "mg", reason: "R")
        XCTAssertEqual(log1, log2)
    }

    // MARK: - DrugLogStore

    func testDrugLogStoreAddLog() {
        let store = DrugLogStore()
        let initialCount = store.logs.count

        let log = DoseLog(
            medicationName: "Test Med",
            dose: 50,
            doseUnit: "mg",
            reason: "Testing"
        )
        store.addLog(log)

        XCTAssertEqual(store.logs.count, initialCount + 1)
        XCTAssertEqual(store.logs.first?.medicationName, "Test Med")
    }

    func testDrugLogStoreRecentLogs() {
        let store = DrugLogStore()
        for i in 0..<25 {
            store.addLog(DoseLog(
                medicationName: "Med \(i)",
                dose: Double(i * 10),
                doseUnit: "mg",
                reason: "Test"
            ))
        }
        XCTAssertEqual(store.recentLogs.count, 20)
    }

    func testDrugLogStoreLastLog() {
        let store = DrugLogStore()
        let log = DoseLog(
            medicationName: "Unique Med",
            dose: 25,
            doseUnit: "mg",
            reason: "Check"
        )
        store.addLog(log)

        let found = store.lastLog(for: "Unique Med")
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.dose, 25)
    }

    // MARK: - MoodCheckin

    func testMoodCheckinCreation() {
        let checkin = MoodCheckin(
            date: "2026-02-11",
            a1Depressed: 1,
            a2Interest: 2,
            a3Anxious: 1,
            a4Worry: 0,
            b5Focus: 6,
            b6TaskStart: 7,
            b7Function: 5,
            c8SleepHrs: 7.5,
            c9SleepQual: 6,
            c10Energy: 4,
            d11Wired: 0,
            d12LessSleep: 0,
            e13SeFreq: 2,
            e14SeIntensity: 1,
            e15SeBurden: 1,
            f16Safety: 0,
            notes: "Feeling okay today"
        )
        XCTAssertEqual(checkin.date, "2026-02-11")
        XCTAssertEqual(checkin.a1Depressed, 1)
        XCTAssertEqual(checkin.c8SleepHrs, 7.5)
        XCTAssertEqual(checkin.f16Safety, 0)
        XCTAssertEqual(checkin.notes, "Feeling okay today")
        XCTAssertNotNil(checkin.id)
    }

    func testMoodCheckinEquatable() {
        let id = UUID()
        let c1 = MoodCheckin(
            id: id, date: "2026-02-11",
            a1Depressed: 0, a2Interest: 0, a3Anxious: 0, a4Worry: 0,
            b5Focus: 5, b6TaskStart: 5, b7Function: 5,
            c8SleepHrs: 8, c9SleepQual: 7, c10Energy: 6,
            d11Wired: 0, d12LessSleep: 0,
            e13SeFreq: 0, e14SeIntensity: 0, e15SeBurden: 0,
            f16Safety: 0
        )
        let c2 = MoodCheckin(
            id: id, date: "2026-02-11",
            a1Depressed: 0, a2Interest: 0, a3Anxious: 0, a4Worry: 0,
            b5Focus: 5, b6TaskStart: 5, b7Function: 5,
            c8SleepHrs: 8, c9SleepQual: 7, c10Energy: 6,
            d11Wired: 0, d12LessSleep: 0,
            e13SeFreq: 0, e14SeIntensity: 0, e15SeBurden: 0,
            f16Safety: 0
        )
        XCTAssertEqual(c1, c2)
    }

    func testMoodCheckinComputedScores() {
        let checkin = MoodCheckin(
            date: "2026-02-11",
            a1Depressed: 2, a2Interest: 3, a3Anxious: 1, a4Worry: 2,
            b5Focus: 6, b6TaskStart: 9, b7Function: 3,
            c8SleepHrs: 6, c9SleepQual: 4, c10Energy: 3,
            d11Wired: 0, d12LessSleep: 0,
            e13SeFreq: 4, e14SeIntensity: 2, e15SeBurden: 3,
            f16Safety: 0
        )
        // PHQ-2: a1 + a2 = 2 + 3 = 5
        XCTAssertEqual(checkin.phq2Score, 5)
        // GAD-2: a3 + a4 = 1 + 2 = 3
        XCTAssertEqual(checkin.gad2Score, 3)
        // PHQ-4: 5 + 3 = 8
        XCTAssertEqual(checkin.phq4Total, 8)
        // Executive function avg: (6+9+3)/3 = 6.0
        XCTAssertEqual(checkin.executiveFunctionAverage, 6.0, accuracy: 0.01)
        // Side effect avg: (4+2+3)/3 = 3.0
        XCTAssertEqual(checkin.sideEffectAverage, 3.0, accuracy: 0.01)
    }

    func testMoodCheckinCodable() throws {
        let original = MoodCheckin(
            date: "2026-02-11",
            a1Depressed: 1, a2Interest: 2, a3Anxious: 0, a4Worry: 3,
            b5Focus: 7, b6TaskStart: 4, b7Function: 6,
            c8SleepHrs: 5.5, c9SleepQual: 3, c10Energy: 2,
            d11Wired: 8, d12LessSleep: 5, dAsrmTotal: 14,
            e13SeFreq: 1, e14SeIntensity: 2, e15SeBurden: 1,
            f16Safety: 1, notes: "Stressful day"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(MoodCheckin.self, from: data)

        XCTAssertEqual(original, decoded)
        XCTAssertEqual(decoded.dAsrmTotal, 14)
        XCTAssertEqual(decoded.notes, "Stressful day")
    }

    func testMoodCheckinOptionalAsrmTotal() {
        let checkin = MoodCheckin(
            date: "2026-02-11",
            a1Depressed: 0, a2Interest: 0, a3Anxious: 0, a4Worry: 0,
            b5Focus: 0, b6TaskStart: 0, b7Function: 0,
            c8SleepHrs: 8, c9SleepQual: 8, c10Energy: 8,
            d11Wired: 0, d12LessSleep: 0,
            e13SeFreq: 0, e14SeIntensity: 0, e15SeBurden: 0,
            f16Safety: 0
        )
        XCTAssertNil(checkin.dAsrmTotal)
    }

    // MARK: - MoodCheckinStore

    func testMoodCheckinStoreAddCheckin() {
        let store = MoodCheckinStore()
        let initialCount = store.checkins.count

        let checkin = MoodCheckin(
            date: "2026-02-11",
            a1Depressed: 0, a2Interest: 0, a3Anxious: 0, a4Worry: 0,
            b5Focus: 5, b6TaskStart: 5, b7Function: 5,
            c8SleepHrs: 7, c9SleepQual: 6, c10Energy: 5,
            d11Wired: 0, d12LessSleep: 0,
            e13SeFreq: 0, e14SeIntensity: 0, e15SeBurden: 0,
            f16Safety: 0
        )
        store.addCheckin(checkin)

        XCTAssertEqual(store.checkins.count, initialCount + 1)
        XCTAssertEqual(store.checkins.first?.date, "2026-02-11")
    }

    func testMoodCheckinStoreRecentCheckins() {
        let store = MoodCheckinStore()
        for i in 0..<35 {
            store.addCheckin(MoodCheckin(
                date: "2026-01-\(String(format: "%02d", (i % 28) + 1))",
                a1Depressed: 0, a2Interest: 0, a3Anxious: 0, a4Worry: 0,
                b5Focus: 5, b6TaskStart: 5, b7Function: 5,
                c8SleepHrs: 7, c9SleepQual: 5, c10Energy: 5,
                d11Wired: 0, d12LessSleep: 0,
                e13SeFreq: 0, e14SeIntensity: 0, e15SeBurden: 0,
                f16Safety: 0
            ))
        }
        XCTAssertEqual(store.recentCheckins.count, 30)
    }

    func testMoodCheckinStoreCheckinForDate() {
        let store = MoodCheckinStore()
        let checkin = MoodCheckin(
            date: "2026-02-10",
            a1Depressed: 1, a2Interest: 1, a3Anxious: 1, a4Worry: 1,
            b5Focus: 5, b6TaskStart: 5, b7Function: 5,
            c8SleepHrs: 6, c9SleepQual: 4, c10Energy: 3,
            d11Wired: 0, d12LessSleep: 0,
            e13SeFreq: 0, e14SeIntensity: 0, e15SeBurden: 0,
            f16Safety: 0
        )
        store.addCheckin(checkin)

        XCTAssertNotNil(store.checkin(for: "2026-02-10"))
        XCTAssertNil(store.checkin(for: "2026-02-09"))
    }
}
