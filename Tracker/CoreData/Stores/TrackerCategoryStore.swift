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

class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var trackerStore = TrackerStore()
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        let sortDescriptor = NSSortDescriptor(keyPath: \TrackerCategoryCoreData.titles, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    var categories: [TrackerCategory] {
        guard
            let objects = self.fetchedResultController.fetchedObjects,
            let categories = try? objects.map({ try self.makeCategories(from: $0) })
        else { return [] }
        return categories
    }
    
    convenience override init() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistantContainer.viewContext
            self.init(context: context)
        } else {
            fatalError("Unable to acces the AppDelegate")
        }
    }
    
//    init(context: NSManagedObjectContext) {
//        self.context = context
//        super.init()
//    }
   
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        super.init()
        
        do {
            try fetchedResultController.performFetch()
        } catch {
            print("Failed to fetch categories: \(error)")
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
                return try? trackerStore.makeTracker(from: coreDataTracker)
            }
            return nil
        })
    }
    
    private func fetchedCategory(with title: String) throws -> TrackerCategoryCoreData? {
        let request = fetchedResultController.fetchRequest
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: ["titles", title])
        do {
            let category = try context.fetch(request)
            return category.first
        } catch {
            throw TrackerCategoryStoreError.decodingErrorInvalidCategoryModel
        }
    }
    
    //добавления трекера в уже существующую категорию
    func createTrackerWithCategory(tracker: Tracker, with titles: String) throws {
        let trackerCoreData = try trackerStore.createTrackerCoreData(from: tracker)
        
        if let currentCategory = try? fetchedCategory(with: titles) {
            guard let trackers = currentCategory.trackers, var newCoreDataTrackers = trackers.allObjects
                    as? [TrackerCoreData] else {return}
            newCoreDataTrackers.append(trackerCoreData)
            currentCategory.trackers = NSSet(array: newCoreDataTrackers)
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.titles = titles
            newCategory.trackers = NSSet(array: [trackerCoreData])
        }
        
        do {
            try context.save()
        } catch {
            print("Unable to save category. Error: \(error), \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(with title: String) throws {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "%K == %@", 
                                        #keyPath(TrackerCategoryCoreData.titles), title)
        
        let categories = try context.fetch(request)
        
        if let categoryToDelete = categories.first {
            context.delete(categoryToDelete)
         
            do {
                try context.save()
            } catch {
                print("Failed to save context after deleting category: \(error)")
                throw error
            }
        }
    }
    
    func createCategory(title: String) throws {
        // Проверяем, существует ли уже категория с таким названием
        if let _ = try? fetchedCategory(with: title) {
            print("Категория с таким названием уже существует")
            return
        }
        
        // Создаём новую категорию
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.titles = title
        newCategory.trackers = []
        
        do {
            try context.save()
        } catch {
            print("Не удалось сохранить категорию: \(error)")
            throw error
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError() }
            insertedIndexes?.insert(indexPath.item)
        case .delete:
            guard let indexPath = indexPath else { fatalError() }
            deletedIndexes?.insert(indexPath.item)
        case .update:
            guard let indexPath = indexPath else { fatalError() }
            updatedIndexes?.insert(indexPath.item)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { fatalError() }
            movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
        @unknown default:
            fatalError()
        }
    }
}
