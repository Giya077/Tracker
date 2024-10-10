////
////  TrackerRecordStore.swift
////  Tracker
////
////  Created by GiyaDev on 17.06.2024.
////
//
import Foundation
import CoreData

final class TrackerRecordStore {
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
    
    func saveCompletedTracker(trackerId: UUID, date: Date) {
        context.performAndWait {
            let record = TrackerRecordCoreData(context: context)
            record.id = trackerId
            record.date = date
            
            do {
                try context.save()
                print("Tracker completed and saved: \(trackerId)")
            } catch {
                print("Failed to save completed tracker: \(error)")
            }
        }
    }
    
    func deleteCompletedTracker(trackerId: UUID, date: Date) {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND date == %@", trackerId as CVarArg, date as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let recordToDelete = results.first {
                context.delete(recordToDelete)
                try context.save()
                print("Completed tracker removed: \(trackerId)")
            }
        } catch {
            print("Failed to delete completed tracker: \(error)")
        }
    }

    func fetchAllRecords() -> [TrackerRecordCoreData] {
        let records = fetchedResultsController?.fetchedObjects ?? []
        print("Fetched records: \(records)")
        return records
    }

    // Подсчет завершенных трекеров
    func completedTrackersCount() -> Int {
        return fetchAllRecords().count
    }
    
    // Подсчет идеальных дней
    func idealDays() -> Int {
        let records = fetchAllRecords()
        let groupedByDay = Dictionary(grouping: records, by: { Calendar.current.startOfDay(for: $0.date!) })
        let idealDays = groupedByDay.filter { $0.value.count == totalTrackersForDay($0.key) }
        return idealDays.count
    }

    func averageCompletedTrackers() -> Int {
        let records = fetchAllRecords()
        let uniqueDates = Set(records.map { Calendar.current.startOfDay(for: $0.date!) })
        return Int(records.count) / Int(uniqueDates.count)
    }

    func bestPeriod() -> (start: Date, end: Date, count: Int)? {
        let records = fetchAllRecords()
        guard !records.isEmpty else { return nil }
        let bestPeriod: (start: Date, end: Date, count: Int)? = nil
        return bestPeriod
    }

    private func totalTrackersForDay(_ date: Date) -> Int {
        return 5 // Пример
    }
}
