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
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "titles", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error fetching categories \(error.localizedDescription)")
        }
    }
    
    func fetchAllCategories() -> [TrackerCategoryCoreData] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    func saveCategory(title: String) {
        context.performAndWait {
            let category = TrackerCategoryCoreData(context: context)
            category.titles = title
            
            do {
                try context.save()
            } catch {
                fatalError("Failed to save category \(error)")
            }
        }
    }
}
