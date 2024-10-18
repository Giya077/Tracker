////
////  TrackerRecordStore.swift
////  Tracker
////
////  Created by GiyaDev on 17.06.2024.
////
//
import Foundation
import CoreData

 class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveCompletedTracker(trackerId: UUID, date: Date) {
        context.performAndWait {
            let record = TrackerRecordCoreData(context: context)
            record.id = trackerId
            record.date = date
            
            do {
                try context.save()
                print("Tracker completed and saved: \(trackerId)")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .trackerRecordsDidChange, object: nil)
                }
            } catch {
                print("Failed to save completed tracker: \(error)")
            }
        }
    }
    
    func deleteCompletedTracker(trackerId: UUID, date: Date) {
        context.performAndWait {
            let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@ AND date == %@", trackerId as CVarArg, date as CVarArg)
            
            do {
                let results = try context.fetch(request)
                if let recordToDelete = results.first {
                    context.delete(recordToDelete)
                    try context.save()
                    print("Completed tracker removed: \(trackerId)")
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .trackerRecordsDidChange, object: nil)
                    }
                }
            } catch {
                print("Failed to delete completed tracker: \(error)")
            }
        }
    }

    func fetchAllRecords() -> [TrackerRecordCoreData] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let records = try context.fetch(fetchRequest)
            print("Fetched records: \(records)")
            return records
        } catch {
            print("Error fetching records: \(error.localizedDescription)")
            return []
        }
    }

    func completedTrackersCount() -> Int {
        return fetchAllRecords().count
    }
    
    func idealDays() -> Int {
        let records = fetchAllRecords()
        let groupedByDay = Dictionary(grouping: records, by: { Calendar.current.startOfDay(for: $0.date!) })
        let idealDays = groupedByDay.filter { $0.value.count == totalTrackersForDay($0.key) }
        return idealDays.count
    }

    func averageCompletedTrackers() -> Int {
        let records = fetchAllRecords()
        guard !records.isEmpty else { return 0 }
        
        let uniqueDates = Set(records.map { Calendar.current.startOfDay(for: $0.date!) })
        guard !uniqueDates.isEmpty else { return 0 }
        
        return records.count / uniqueDates.count
    }

    func bestPeriod() -> Int? {
        let records = fetchAllRecords()
        guard !records.isEmpty else { return nil }
        
        // Получаем уникальные даты, игнорируя время
        let dates = Set(records.compactMap { $0.date }.map { Calendar.current.startOfDay(for: $0) })
        let sortedDates = dates.sorted()
        guard !sortedDates.isEmpty else { return nil }
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i - 1]
            let currentDate = sortedDates[i]
            
            let components = Calendar.current.dateComponents([.day], from: previousDate, to: currentDate)
            if components.day == 1 {
                // Даты последовательны
                currentStreak += 1
                if currentStreak > maxStreak {
                    maxStreak = currentStreak
                }
            } else if components.day ?? 0 > 1 {
                // Обнаружен разрыв в днях
                currentStreak = 1
            }
        }
        
        return maxStreak
    }

    private func totalTrackersForDay(_ date: Date) -> Int {
        return 5
    }
}

extension Notification.Name {
    static let trackerRecordsDidChange = Notification.Name("trackerRecordsDidChange")
}
