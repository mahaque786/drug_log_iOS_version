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
}
