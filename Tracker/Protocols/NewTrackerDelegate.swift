//
//  NewTrackerDelegate.swift
//  Tracker
//
//  Created by GiyaDev on 21.05.2024.
//

import Foundation

protocol NewTrackerDelegate: AnyObject {
    func didFinishCreatingTracker(trackerType: TrackerType)
}
