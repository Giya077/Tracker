//
//  NewCategoryViewControllerDelegate.swift
//  Tracker
//
//  Created by GiyaDev on 20.05.2024.
//

import Foundation

protocol NewCategoryViewControllerDelegate: AnyObject {
    func didAddCategory(_ category: TrackerCategory)
    func removeStubAndShowCategories()
}
