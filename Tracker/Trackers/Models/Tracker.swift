//
//  Tracker.swift
//  Tracker
//
//  Created by GiyaDev on 10.05.2024.
//

import Foundation
import UIKit


struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: Character
    let schedule: [Days]
}

enum Days {
    case everyday, weekends
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}
