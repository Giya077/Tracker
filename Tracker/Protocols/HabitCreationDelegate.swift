//
//  HabitCreationDelegate.swift
//  Tracker
//
//  Created by GiyaDev on 26.05.2024.
//

import Foundation
import UIKit

protocol HabitCreationDelegate: AnyObject {
    func didCreateTracker(name: String, category: TrackerCategory, schedule: [Days], color: UIColor, emoji: Character)
    func didCreateTrackerSuccessfully(_ tracker: Tracker)
}
