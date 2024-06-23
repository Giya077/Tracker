import Foundation
import CoreData
import UIKit

class TrackerStore {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?

    init(context: NSManagedObjectContext) {
        self.context = context
        setupFetchedResultsController()
    }

    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Error fetching trackers: \(error.localizedDescription)")
        }
    }

    func fetchAllTrackers() -> [TrackerCoreData] {
        return fetchedResultsController?.fetchedObjects ?? []
    }

    func saveTracker(_ tracker: Tracker, to category: TrackerCategoryCoreData) {
        context.perform {
            let newTracker = TrackerCoreData(context: self.context)
            newTracker.id = tracker.id
            newTracker.name = tracker.name
            newTracker.color = tracker.color
            newTracker.emoji = String(tracker.emoji)
            newTracker.schedule = tracker.schedule.map { $0.rawValue } as NSObject

            do {
                try self.context.save()
            } catch {
                print("Failed to save tracker: \(error)")
            }
        }
    }
}
