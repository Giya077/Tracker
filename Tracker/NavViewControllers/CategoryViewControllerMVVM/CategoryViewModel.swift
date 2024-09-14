import Foundation

final class CategoryViewModel {
    
    // MARK: - PRIVATE Properties
    private let trackerCategoryStore: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = []
    
    // Bindings (замыкания) для обновления UI
    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    var onCategoryDeleted: (([TrackerCategory]) -> Void)?
    var onShowStub: ((Bool) -> Void)?
    var selectedCategoryIndex: Int?
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        self.categories = trackerCategoryStore.categories
        fetchCategories()
    }
    
    func fetchCategories() {
        categories = trackerCategoryStore.categories
        onCategoriesChanged?()
        onShowStub?(categories.isEmpty)
    }
    
    func addCategory(_ title: String) {
        do {
            try trackerCategoryStore.createCategory(with: title)
            fetchCategories()
        } catch {
            print("Ошибка при добавлении категории: \(error)")
        }
    }
    
    func deleteCategory(at index: Int) {
         let category = categories[index]
         do {
             try trackerCategoryStore.deleteCategory(with: category.titles)
             fetchCategories()
             
             // Корректируем выбранный индекс
             if let selectedIndex = selectedCategoryIndex {
                 if selectedIndex == index {
                     selectedCategoryIndex = nil  // Сбрасываем выбор, если удалили выбранную категорию
                 } else if selectedIndex > index {
                     selectedCategoryIndex = selectedIndex - 1  // Корректируем индекс для оставшихся категорий
                 }
             }
             onCategoryDeleted?(categories)
         } catch {
             print("Ошибка при удалении категории: \(error)")
         }
     }
    
    func updateCategory(at index: Int, with newTitle: String) {
        let oldCategory = categories[index]
        do {
            try trackerCategoryStore.updateCategory(oldTitle: oldCategory.titles, newTitle: newTitle)
            fetchCategories()
        } catch {
            print("Ошибка при обновлении категории: \(error)")
        }
    }
    
    func selectCategory(at index: Int) {
        selectedCategoryIndex = index
        onCategorySelected?(categories[index])
    }
}
