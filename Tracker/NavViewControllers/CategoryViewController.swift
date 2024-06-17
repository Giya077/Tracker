//
//  CategoryViewController.swift
//  Tracker
//
//  Created by GiyaDev on 14.05.2024.
//

import UIKit

class CategoryViewController: UIViewController, NewCategoryViewControllerDelegate {
    
    weak var delegate: NewCategoryViewControllerDelegate? // для связи между AddCategoryViewController и CategoryViewController
    weak var habitDelegate: HabitViewController?
    weak var categorySelectionDelegate: CategorySelectionDelegate?
    private var selectedCategories: Set<Int> = []
    
    var categories: [TrackerCategory] = [] {
        didSet {
            tableView.reloadData()
            updateViewVisibility()
        }
    }
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupView()
        setupStubView()
        setupTableView()
        updateViewVisibility()
        addCategoryViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData() // Обновляем таблицу при появлении контроллера на экране
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
    
    private func addCategoryViewController() {
        let addCategoryViewController = AddCategoryViewController()
        addCategoryViewController.delegate = self
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
        if categories.isEmpty {
            stubView.isHidden = false
            tableView.isHidden = true
        } else {
            stubView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    @objc
    private func addCategoryButtonTapped() {
        let addCategoryViewController = AddCategoryViewController()
        addCategoryViewController.delegate = self
        let nav = UINavigationController(rootViewController: addCategoryViewController)
        present(nav, animated: true)
    }
    
    func removeStubAndShowCategories() {
        updateViewVisibility()
    }
    
    func didAddCategory(_ category: TrackerCategory) {
        categories.append(category)
        removeStubAndShowCategories()
        dismiss(animated: true)
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Обновляем множество выбранных категорий
        
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
}
