import Foundation
import CoreData
import UIKit

enum TrackerStoreError: Error {
    case decodingErrorInvalidItem
}

final class TrackerStore: NSObject {
    
    //Хранит экземпляр NSManagedObjectContext, который используется для взаимодействия с базой данных Core Data
    private let context: NSManagedObjectContext

    //автоматически управляет получением данных из Core Data и их отображением
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCoreData> = {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let sortDescriptor = NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        request.sortDescriptors = [sortDescriptor]
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try? controller.performFetch()
        return controller
    }()
    
    var trackers: [Tracker] {
        guard
            let objects = fetchedResultController.fetchedObjects,
            let trackers = try? objects.map({ try makeTracker(from: $0) })
        else { return [] }
        return trackers
    }
    
    convenience override init() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistantContainer.viewContext
            self.init(context: context)
        } else {
            fatalError("Unable to access the AppDelegate")
        }
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func makeTracker(from trackersCoreData: TrackerCoreData) throws -> Tracker {
        guard
            let id = trackersCoreData.id,
            let name = trackersCoreData.name,
            let colorData = trackersCoreData.color as? Data,
            let emojiString = trackersCoreData.emoji,
            let scheduleData = trackersCoreData.schedule as? Data,
            let color = ColorValueTransformer().reverseTransformedValue(colorData) as? UIColor,
            let emoji = emojiString.first,
            let schedule = ScheduleValueTransformer().reverseTransformedValue(scheduleData) as? [Days]
        else {
            throw TrackerStoreError.decodingErrorInvalidItem
        }
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: String(emoji),
            schedule: schedule
        )
    }
    
    func createTracker(from tracker: Tracker) throws -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = ColorValueTransformer().transformedValue(tracker.color) as? NSData
        trackerCoreData.emoji = String(tracker.emoji)
        trackerCoreData.schedule = ScheduleValueTransformer().transformedValue(tracker.schedule) as? NSData
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
}
