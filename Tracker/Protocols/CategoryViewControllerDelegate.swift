//
//  CategoryViewControllerDelegate.swift
//  Tracker
//
//  Created by GiyaDev on 21.05.2024.
//

import Foundation

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}
