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
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveRecord(id: UUID, date: Date) {
        let record = TrackerRecordCoreData(context: context)
        record.id = id
        record.date = date
        
        do {
            try context.save()
        } catch {
            fatalError("Failed to save record \(error)")
        }
    }
}
