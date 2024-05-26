//
//  HabitCreationDelegate.swift
//  Tracker
//
//  Created by GiyaDev on 26.05.2024.
//

import Foundation

protocol HabitCreationDelegate: AnyObject {
    func didCreateTracker(name: String, category: TrackerCategory, schedule: [Days])
    func didCreateTrackerSuccessfully(_ tracker: Tracker)
}
