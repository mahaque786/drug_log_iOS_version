//
//  DrugLogTests.swift
//  DrugLogTests
//
//  Unit tests for the Drug Log application.
//

import XCTest
@testable import DrugLog

class DrugLogTests: XCTestCase {
    
    func testDrugEntryCreation() {
        let entry = DrugEntry(
            name: "Test Medicine",
            dosage: "50mg",
            frequency: "Twice daily"
        )
        
        XCTAssertEqual(entry.name, "Test Medicine")
        XCTAssertEqual(entry.dosage, "50mg")
        XCTAssertEqual(entry.frequency, "Twice daily")
        XCTAssertNil(entry.lastTaken)
    }
    
    func testDrugLogStoreAddEntry() {
        let store = DrugLogStore()
        let initialCount = store.entries.count
        
        let entry = DrugEntry(
            name: "Test Medicine",
            dosage: "50mg",
            frequency: "Twice daily"
        )
        
        store.add(entry)
        
        XCTAssertEqual(store.entries.count, initialCount + 1)
        XCTAssertTrue(store.entries.contains { $0.id == entry.id })
    }
    
    func testDrugLogStoreDeleteEntry() {
        let store = DrugLogStore()
        let entry = DrugEntry(
            name: "Test Medicine",
            dosage: "50mg",
            frequency: "Twice daily"
        )
        
        store.add(entry)
        let countAfterAdd = store.entries.count
        
        store.delete(entry)
        
        XCTAssertEqual(store.entries.count, countAfterAdd - 1)
        XCTAssertFalse(store.entries.contains { $0.id == entry.id })
    }
    
    func testMarkAsTaken() {
        let store = DrugLogStore()
        let entry = DrugEntry(
            name: "Test Medicine",
            dosage: "50mg",
            frequency: "Twice daily"
        )
        
        store.add(entry)
        
        // Verify the entry was added and initially has no lastTaken value
        guard let addedEntry = store.entries.first(where: { $0.id == entry.id }) else {
            XCTFail("Entry not found after adding")
            return
        }
        XCTAssertNil(addedEntry.lastTaken)
        
        store.markAsTaken(entry)
        
        if let updatedEntry = store.entries.first(where: { $0.id == entry.id }) {
            XCTAssertNotNil(updatedEntry.lastTaken)
        } else {
            XCTFail("Entry not found after marking as taken")
        }
    }
}
