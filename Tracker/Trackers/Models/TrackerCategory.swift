//
//  TrackerCategory.swift
//  Tracker
//
//  Created by GiyaDev on 10.05.2024.
//

import Foundation

struct TrackerCategory {
    let titles: String // Название категории
    var trackers: [Tracker] // Массив трекеров в данной категории
    

    init(titles: String, trackers: [Tracker] = []) {
        self.titles = titles
        self.trackers = trackers
    }
}
