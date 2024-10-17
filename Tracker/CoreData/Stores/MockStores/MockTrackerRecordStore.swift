import Foundation
import CoreData

final class MockTrackerRecordStore: TrackerRecordStore {
    init() {
        let persistentContainer = NSPersistentContainer(name: "Model")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Ошибка загрузки in-memory хранилища: \(error)")
            }
        }
        let context = persistentContainer.viewContext
        super.init(context: context)
    }
    
    override func fetchAllRecords() -> [TrackerRecordCoreData] {
        return []
    }
}
