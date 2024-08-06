

import UIKit

final class CategoryViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: NewCategoryViewControllerDelegate?
    weak var trackerCategoryStoreDelegate: TrackerCategoryStoreDelegate?
    weak var categorySelectionDelegate: CategorySelectionDelegate?
    
    var categories: [TrackerCategory] = [] {
        didSet {
            tableView.reloadData()
            updateViewVisibility()
        }
    }
    // MARK: - Private Properties
    private var selectedCategories: Set<Int> = []
    private let trackerCategoryStore: TrackerCategoryStore
    private lazy var stubView = StubView(text: "Привычки и события можно\nобъединить по смыслу")
    private lazy var label: UILabel = {
        let label = BasicTextLabel(text: "Категория")
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let addCategoryButton = BasicButton(title: "Добавить категорию")
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        return addCategoryButton
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    // MARK: - Initializers
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        super.init(nibName: nil, bundle: nil)
        
        //Загрузка категорий из Core Data
        self.categories = trackerCategoryStore.categories
        trackerCategoryStore.trackerCategoryStoreDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupView()
        setupStubView()
        setupTableView()
        updateViewVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(label)
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    private func setupStubView() {
        view.addSubview(stubView)
        stubView.textLabel.numberOfLines = 2
        
        NSLayoutConstraint.activate([
            stubView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stubView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -20)
        ])
    }
        
    private func updateViewVisibility() {
        stubView.isHidden = !categories.isEmpty
        tableView.isHidden = categories.isEmpty
    }
    
    private func updateCategories() {
        self.categories = trackerCategoryStore.categories
    }
    
    private func editCategory(at indexPath: IndexPath) {
        let category = categories[indexPath.row]
        let alertController = UIAlertController(title: "Редактировать категорию", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = category.titles
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let newName = alertController.textFields?.first?.text else { return }
            
            do {
                try self? .trackerCategoryStore.updateCategory(oldTitle: category.titles, newTitle: newName)
                self?.updateCategories()
            } catch {
                print("Failed to update category: \(error)")
            }
        }
        alertController.addAction(saveAction)
        present(alertController, animated: true)
    }
    
    private func deleteCategory(at indexPath: IndexPath) {
        let category = categories[indexPath.row]
        
        do {
            try trackerCategoryStore.deleteCategory(with: category.titles)
            
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
    
    private func presentActions(for indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let editAction = UIAlertAction(title: "Редактировать", style: .default) { [weak self] _ in
            self?.editCategory(at: indexPath)
        }

        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.deleteCategory(at: indexPath)
        }

        alertController.addAction(editAction)
        alertController.addAction(deleteAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @objc
    private func addCategoryButtonTapped() {
        let addCategoryViewController = AddCategoryViewController(trackerCategoryStore: trackerCategoryStore)
        addCategoryViewController.delegate = self
        addCategoryViewController.trackerCategoryStoreDelegate = trackerCategoryStoreDelegate
        let nav = UINavigationController(rootViewController: addCategoryViewController)
        present(nav, animated: true)
    }
}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category = categories[indexPath.row]
        let isSelected = selectedCategories.contains(indexPath.row)
        cell.configure(withTitle: category.titles, backgroundColor: Colors.systemSearchColor!, isSelected: isSelected)
        
        cell.onLongPress = { [weak self, weak cell] in
            guard let self = self else { return }
            let point = cell?.center ?? CGPoint.zero
            let indexPath = tableView.indexPathForRow(at: point) ?? indexPath
            self.presentActions(for: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCategoryIndex = indexPath.row
        if selectedCategories.contains(selectedCategoryIndex) {
            selectedCategories.remove(selectedCategoryIndex)
        } else {
            selectedCategories.removeAll()
            selectedCategories.insert(selectedCategoryIndex)
        }
        // Если у делегата есть метод didSelectCategory, вызываем его и передаем выбранную категорию
        if let selectedCategory = selectedCategories.first.map({ categories[$0] }) {
            categorySelectionDelegate?.didSelectCategory(selectedCategory)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = categories[indexPath.row]
            do {
                try trackerCategoryStore.deleteCategory(with: category.titles)
            } catch {
                print("Failed to delete category: \(error)")
            }
        }
    }
}

extension CategoryViewController: TrackerCategoryStoreDelegate {
    
    func categoryDidUpdate(_ updatedCategory: TrackerCategory) {
        if let index = categories.firstIndex(where: { $0.titles == updatedCategory.titles }) {
            categories[index] = updatedCategory
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    func categoriesDidChange() {
        updateCategories()
        tableView.reloadData()
    }
}

extension CategoryViewController: NewCategoryViewControllerDelegate {
    
    func removeStubAndShowCategories() {
        updateViewVisibility()
    }
    
    func didAddCategory(_ category: TrackerCategory) {
        categories.append(category)
        removeStubAndShowCategories()
        dismiss(animated: true)
    }
}
