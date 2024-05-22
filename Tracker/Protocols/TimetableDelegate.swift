//
//  TimetableDelegate.swift
//  Tracker
//
//  Created by GiyaDev on 17.05.2024.
//

import Foundation


protocol TimetableDelegate: AnyObject {
    func didUpdateSelectedDays(_ selectedDays: Set<Days>)
}
