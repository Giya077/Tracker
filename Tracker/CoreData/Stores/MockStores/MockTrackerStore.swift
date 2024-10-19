//
//  MockTrackerStore.swift
//  Tracker
//
//  Created by GiyaDev on 25.09.2024.
//

import Foundation

final class MockTrackerStore: TrackerStore {
    override func loadTrackerFromCoreData(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        return Tracker(id: UUID(), name: "Test Tracker", color: .red, emoji: "🎯", schedule: [.monday, .wednesday, .friday,.sunday,.thursday])
    }
}
