//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by GiyaDev on 17.06.2024.
//

import Foundation
import CoreData

class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveCategory(title: String) {
        let category = TrackerCategoryCoreData(context: context)
        category.titles = title
        
        do {
            try context.save()
        } catch {
            fatalError("Failed to save category: \(error)")
        }
    }
}
