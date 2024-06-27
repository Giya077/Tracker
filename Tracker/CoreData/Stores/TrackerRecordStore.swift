//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by GiyaDev on 17.06.2024.
//

import Foundation
import CoreData

class TrackerRecordStore {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error fetching records \(error.localizedDescription)")
        }
    }
    
    func fetchAllRecords() -> [TrackerRecordCoreData] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
//    func saveRecord(id: UUID, date: Date) {
//        let record = TrackerRecordCoreData(context: context)
//        record.id = id
//        record.date = date
//        
//        do {
//            try context.save()
//        } catch {
//            fatalError("Failed to save record \(error)")
//        }
//    }
    
    func saveRecord(date: Date) {
        context.performAndWait {
            let record = TrackerRecordCoreData(context: context)
            record.id = UUID()
            record.date = date
            
            do {
                try context.save()
            } catch {
                fatalError("Failed to save record \(error)")
            }
        }
    }
}
