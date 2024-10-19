import Foundation
import CoreData
import UIKit

enum TrackerStoreError: Error {
    case decodingErrorInvalidItem
    case saveFailed
    case failedToFetchTrackers
}

 class TrackerStore: NSObject {
    
    // MARK: - Public Properties
    var trackers: [Tracker] {
        guard
            let objects = fetchedResultController.fetchedObjects,
            let trackers = try? objects.map({ try loadTrackerFromCoreData(from: $0) })
        else { return [] }
        return trackers
    }
    
    // MARK: - Private Properties
    private let colorTransformedToData = ColorTransformedToData()
    private let scheduleTransformedToData = ScheduleTransformedToData()
    private let context: NSManagedObjectContext
    
    private func createFetchedResultsController() throws -> NSFetchedResultsController<TrackerCoreData> {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let sortDescriptor = NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        do {
            try controller.performFetch()
        } catch {
            throw TrackerStoreError.failedToFetchTrackers
        }
        return controller
    }
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCoreData> = {
        do {
            return try createFetchedResultsController()
        } catch {
            assertionFailure("Failed to initialize FetchedResultsController: \(error)")
            return NSFetchedResultsController()
        }
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
        super.init()
    }
        
    func loadTrackerFromCoreData(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard
            let id = trackerCoreData.id,
            let name = trackerCoreData.name,
            let colorHex = trackerCoreData.color,
            let scheduleString = trackerCoreData.schedule,
            let emoji = trackerCoreData.emoji
        else {
            throw TrackerStoreError.decodingErrorInvalidItem
        }

        let color = colorTransformedToData.color(from: colorHex)
        let schedule = scheduleTransformedToData.makeWeekDayArrayFromString(scheduleString)
            .compactMap { Days(rawValue: $0) }
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    func createTrackerCoreData(from tracker: Tracker) throws -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = colorTransformedToData.hexString(from: tracker.color)
        trackerCoreData.emoji = String(tracker.emoji)
        trackerCoreData.schedule = scheduleTransformedToData.makeStringFromArray(tracker.schedule.map { $0.rawValue })
        
        do {
            try context.save()
        } catch {
            throw TrackerStoreError.saveFailed
        }
        
        return trackerCoreData
    }

    
    func deleteTracker(with id: UUID) throws {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let trackers = try context.fetch(request)
        if let trackerDelete = trackers.first {
            context.delete(trackerDelete)
            do {
                try context.save()
            } catch {
                print("Failed to save context after deleting tracker: \(error)")
                throw error
            }
        }
    }
    
    func fetchAllTrackers() -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            let results = try context.fetch(request)
            return results.compactMap { trackerCoreData in
                try? loadTrackerFromCoreData(from: trackerCoreData)
            }
        } catch {
            print("Failed to fetch trackers: \(error)")
            return []
        }
    }
}
