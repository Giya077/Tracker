//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by GiyaDev on 17.06.2024.
//

import Foundation
import CoreData
import UIKit

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTitle
    case decodingErrorInvalidCategory
    case decodingErrorInvalidCategoryModel
}

 class TrackerCategoryStore: NSObject{
    
    // MARK: - Public Properties
    weak var trackerCategoryStoreDelegate: TrackerCategoryStoreDelegate?
  
    var categories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let categories = try? objects.map({ try self.makeCategories(from: $0) })
        else { return [] }
        return categories
    }
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    private var trackerStore: TrackerStore
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
        
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.titles, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unresolved error \(error)")
        }
        
        return fetchedResultsController
    }()
    
    convenience override init() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistantContainer.viewContext
            self.init(context: context)
        } else {
            print("Unable to acces the AppDelegate")
            self.init(context: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        super.init()
    }
            
    func fetchAllCategories() -> [TrackerCategoryCoreData] {
        return fetchedResultsController.fetchedObjects ?? []
    }
    
    func deleteCategory(with title: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "titles == %@", title)
        
        let categories = try context.fetch(fetchRequest)
        if let category = categories.first {
            if let trackers = category.trackers as? Set<TrackerCoreData> {
                for tracker in trackers {
                    context.delete(tracker)
                }
            }
            context.delete(category)
            try context.save()
        }
    }
    
    func createCategory(with title: String) throws {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.titles = title
        try context.save()
    }
        
    func updateCategory(oldTitle: String, newTitle: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "titles == %@", oldTitle)
        
        if let category = try context.fetch(fetchRequest).first {
            category.titles = newTitle
            try context.save()
            
            reloadFetchedResultsController()
            let updatedCategory = try self.makeCategories(from: category)
            trackerCategoryStoreDelegate?.categoryDidUpdate(updatedCategory)
        }
    }
        
    func saveTracker(_ tracker: Tracker, forCategoryTitle categoryTitle: String) {
        do {
            let trackerCoreData = try trackerStore.createTrackerCoreData(from: tracker)
            let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "titles == %@", categoryTitle)
            let categories = try context.fetch(fetchRequest)
            
            if let currentCategory = categories.first {
                // Добавление трекера в категорию
                if let trackers = currentCategory.trackers?.allObjects as? [TrackerCoreData] {
                    var updatedTrackers = trackers
                    updatedTrackers.append(trackerCoreData)
                    currentCategory.trackers = NSSet(array: updatedTrackers)
                } else {
                    currentCategory.trackers = NSSet(array: [trackerCoreData])
                }
            } else {
                // Создание новой категории, если она не найдена
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.titles = categoryTitle
                newCategory.trackers = NSSet(array: [trackerCoreData])
            }
            try context.save()
            trackerCategoryStoreDelegate?.categoriesDidChange()
        } catch {
            print("Unable to save tracker. Error: \(error), \(error.localizedDescription)")
        }
    }
    
    //преобразования данных из Core Data в модели
    private func makeCategories(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryCoreData.titles else {
            throw TrackerCategoryStoreError.decodingErrorInvalidTitle
        }
        
        guard let trackers = trackerCategoryCoreData.trackers else {
            throw TrackerCategoryStoreError.decodingErrorInvalidCategory
        }
        
        return TrackerCategory(titles: title, trackers: trackers.compactMap { coreDataTracker -> Tracker? in
            if let coreDataTracker = coreDataTracker as? TrackerCoreData {
                return try? trackerStore.loadTrackerFromCoreData(from: coreDataTracker)
            }
            return nil
        })
    }
    
    private func reloadFetchedResultsController() {
         do {
             try fetchedResultsController.performFetch()
             trackerCategoryStoreDelegate?.categoriesDidChange()
         } catch {
             print("Failed to fetch categories: \(error)")
         }
     }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else {
                print("Insert indexPath is nil")
                return
            }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else {
                print("Delete indexPath is nil")
                return
            }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else {
                print("Update indexPath is nil")
                return
            }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else {
                print("Move indexPaths are nil")
                return
            }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            print("Unknown NSFetchedResultsChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        trackerCategoryStoreDelegate?.categoriesDidChange()
    }
}

