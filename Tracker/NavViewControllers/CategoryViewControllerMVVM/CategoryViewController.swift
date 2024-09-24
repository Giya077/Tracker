import UIKit

final class CategoryViewController: UIViewController {
    
    // MARK: - Privat Properties
    private var viewModel: CategoryViewModel
    private lazy var stubView = StubView(text: NSLocalizedString("Habits and events can be\ncombined by meaning", comment: "Stub text for empty category screen"))
    
    private lazy var label: UILabel = {
        let label = BasicTextLabel(text: NSLocalizedString("Category", comment: "Category label"))
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let addCategoryButton = BasicButton(title: NSLocalizedString("Add Category", comment: "Button to add a new category"))
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        return addCategoryButton
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    // MARK: - Public Properties
    
    var onCategorySelected: ((TrackerCategory) -> Void)?
    
    // MARK: - Initializers
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        viewModel.fetchCategories()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = ThemeManager.shared.backgroundColor()
        view.addSubview(label)
        view.addSubview(addCategoryButton)
        view.addSubview(stubView)
        stubView.textLabel.numberOfLines = 2
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            
            tableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -20),
            
            stubView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.onShowStub = { [weak self] shouldShowStub in
            self?.stubView.isHidden = !shouldShowStub
            self?.tableView.isHidden = shouldShowStub
        }
    }

    private func presentActions(for indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: NSLocalizedString("Edit", comment: "Edit category action"), style: .default) { [weak self] _ in
            self?.editCategory(at: indexPath)
        }
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete category action"), style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: indexPath.row)
            self?.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel) { _ in }
        
        alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)

        if let popoverController = alertController.popoverPresentationController {
            let cell = tableView.cellForRow(at: indexPath)
            popoverController.sourceView = cell
            popoverController.sourceRect = cell?.bounds ?? CGRect.zero
        }
        
        present(alertController, animated: true)
    }

    private func editCategory(at indexPath: IndexPath) {
        let category = viewModel.categories[indexPath.row]
        let alertController = UIAlertController(title: NSLocalizedString("", comment: "Edit category title"), message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = category.titles
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel)
        let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Save category action"), style: .default) { [weak self] _ in
            if let newName = alertController.textFields?.first?.text, !newName.isEmpty {
                self?.viewModel.updateCategory(at: indexPath.row, with: newName)
                
                // Сбрасываем выбор только если редактируется выбранная категория
                if self?.viewModel.selectedCategoryIndex == indexPath.row {
                    self?.viewModel.selectedCategoryIndex = nil
                }
                self?.tableView.reloadData()
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true)
    }
    
    // MARK: - Actions
    @objc
    private func addCategoryButtonTapped() {
        let alertController = UIAlertController(title: NSLocalizedString("New Category", comment: "New category title"), message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = NSLocalizedString("Enter category name", comment: "Category name placeholder")
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel)
        let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: "Save action"), style: .default) { [weak self] _ in
            if let categoryName = alertController.textFields?.first?.text, !categoryName.isEmpty {
                self?.viewModel.addCategory(categoryName)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true)
    }
}


extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category = viewModel.categories[indexPath.row]
        
        // Проверка, выбрана ли категория
        let isSelected = indexPath.row == viewModel.selectedCategoryIndex
        let backgroundColor: UIColor = isSelected ? .lightGray : (Colors.systemSearchColor ?? .white)
        
        cell.configure(withTitle: category.titles, backgroundColor: backgroundColor, isSelected: isSelected)

        cell.onLongPress = { [weak self] in
            self?.presentActions(for: indexPath)
        }
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        onCategorySelected?(viewModel.categories[indexPath.row])
        navigationController?.popViewController(animated: true)
        tableView.reloadData()
    }
}
