//
//  TrackerStore.swift
//  Tracker
//
//  Created by GiyaDev on 17.06.2024.
//

import Foundation
import CoreData
import UIKit

class TrackerStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchAllTrackers() -> [TrackerCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Ошибка при получении данных о трекерах: \(error)")
            return []
        }
    }
    
    func saveTracker(name: String, color: UIColor, emoji: String, schedule: [Days]) {
        context.performAndWait {
            let tracker = TrackerCoreData(context: context)
            tracker.id = UUID()
            tracker.name = name
            tracker.color = color
            tracker.emoji = emoji
            tracker.schedule = schedule as NSObject
            
            do {
                try context.save()
            } catch {
                fatalError("Failed to save tracker: \(error)")
            }
        }
    }
}

