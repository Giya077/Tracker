import CoreData
import UIKit

final class MockTrackerCategoryStore: TrackerCategoryStore {
    
    override func fetchAllCategories() -> [TrackerCategoryCoreData] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistantContainer.viewContext
        
        let mockTrackerCoreData = TrackerCoreData(context: context)
        mockTrackerCoreData.id = UUID()
        mockTrackerCoreData.name = "Test Tracker"
        mockTrackerCoreData.color = ColorTransformedToData().hexString(from: UIColor.red)
        mockTrackerCoreData.emoji = "🎯"
        
        let mockSchedule: [String] = ["Пт", "Сб"]
        mockTrackerCoreData.schedule = ScheduleTransformedToData().makeStringFromArray(mockSchedule)

        let mockCategoryCoreData = TrackerCategoryCoreData(context: context)
        mockCategoryCoreData.titles = "Test Category"
        mockCategoryCoreData.trackers = NSSet(object: mockTrackerCoreData)
        
        return [mockCategoryCoreData]
    }
}

extension UIColor {
    func toData() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}
