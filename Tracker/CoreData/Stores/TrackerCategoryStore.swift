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
    
    private let context: NSManagedObjectContext
    private var trackerStore: TrackerStore
    weak var trackerCategoryStoreDelegate: TrackerCategoryStoreDelegate?
    
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
            fatalError("Unresolved error \(error)")
        }
        
        return fetchedResultsController
    }()
    
    
        var categories: [TrackerCategory] {
            guard
                let objects = self.fetchedResultsController.fetchedObjects,
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
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        super.init()
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
    
    private func fetchedCategory(with title: String) throws -> TrackerCategoryCoreData? {
        let request = fetchedResultsController.fetchRequest
        request.predicate = NSPredicate(format: "titles == %@", title)
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
            //            trackerCategoryStoreDelegate?.categoriesDidChange()
        } catch {
            print("Unable to save category. Error: \(error), \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(with title: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "titles == %@", title)
        
        if let category = try context.fetch(fetchRequest).first {
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
        }
    }
        
    func saveTracker(_ tracker: Tracker, forCategoryTitle categoryTitle: String) {
        do {
            // Создание TrackerCoreData из Tracker
            let trackerCoreData = try trackerStore.createTrackerCoreData(from: tracker)
            
            // Поиск категории
            if let currentCategory = try fetchedCategory(with: categoryTitle) {
                // Добавление трекера в категорию
                if let trackers = currentCategory.trackers, var newCoreDataTrackers = trackers.allObjects as? [TrackerCoreData] {
                    newCoreDataTrackers.append(trackerCoreData)
                    currentCategory.trackers = NSSet(array: newCoreDataTrackers)
                } else {
                    currentCategory.trackers = NSSet(array: [trackerCoreData])
                }
            } else {
                // Создание новой категории, если она не найдена
                let newCategory = TrackerCategoryCoreData(context: context)
                newCategory.titles = categoryTitle
                newCategory.trackers = NSSet(array: [trackerCoreData])
            }
            
            // Сохранение контекста
            try context.save()
            // Уведомление делегата об изменениях
            trackerCategoryStoreDelegate?.categoriesDidChange()
        } catch {
            print("Unable to save tracker. Error: \(error), \(error.localizedDescription)")
        }
    }

    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        trackerCategoryStoreDelegate?.categoriesDidChange()
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

