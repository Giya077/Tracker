//
//  Days.swift
//  Tracker
//
//  Created by GiyaDev on 15.05.2024.
//

import Foundation


enum Days: String, CaseIterable, Codable {
    case monday = "Пн"
    case tuesday = "Вт"
    case wednesday = "Ср"
    case thursday = "Чт"
    case friday = "Пт"
    case saturday = "Сб"
    case sunday = "Вс"
    
    var localizedShortName: String {
        switch self {
        case .monday:
            return NSLocalizedString("monday_short", comment: "Short form for Monday")
        case .tuesday:
            return NSLocalizedString("tuesday_short", comment: "Short form for Tuesday")
        case .wednesday:
            return NSLocalizedString("wednesday_short", comment: "Short form for Wednesday")
        case .thursday:
            return NSLocalizedString("thursday_short", comment: "Short form for Thursday")
        case .friday:
            return NSLocalizedString("friday_short", comment: "Short form for Friday")
        case .saturday:
            return NSLocalizedString("saturday_short", comment: "Short form for Saturday")
        case .sunday:
            return NSLocalizedString("sunday_short", comment: "Short form for Sunday")
        }
    }
}

extension Days {
    init?(dayNumber: Int) {
        switch dayNumber {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: return nil
        }
    }
}


