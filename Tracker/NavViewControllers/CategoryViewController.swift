//
//  CategoryViewController.swift
//  Tracker
//
//  Created by GiyaDev on 14.05.2024.
//

import Foundation
import UIKit

class CategoryViewController: UIViewController, NewCategoryViewControllerDelegate {
    
    private var selectedCategories: Set<Int> = []
    
    weak var delegate: NewCategoryViewControllerDelegate? // для связи между AddCategoryViewController и CategoryViewController

    var categories: [TrackerCategory] = [] {
        didSet {
            tableView.reloadData()
            updateViewVisibility()
        }
    }

    private let stubView = StubView(text: "Привычки и события можно\nобъединить по смыслу")
    
    private let categoryLabel: UILabel = {
        let categoryLabel = UILabel()
        categoryLabel.text = "Категория"
        categoryLabel.textColor = .black
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 18)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        return categoryLabel
    }()
    
    private let addCategoryButton: UIButton = {
        let addCategoryButton = UIButton(type: .system)
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        addCategoryButton.backgroundColor = .black
        addCategoryButton.tintColor = .white
        addCategoryButton.layer.cornerRadius = 16
        addCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        addCategoryButton.layer.shadowColor = UIColor.black.cgColor
        addCategoryButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addCategoryButton.layer.shadowOpacity = 0.5
        addCategoryButton.layer.shadowRadius = 4
        return addCategoryButton
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStubView()
        setupTableView()
        updateViewVisibility()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(categoryLabel)
        view.addSubview(addCategoryButton)
        
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            categoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addCategoryButton.heightAnchor.constraint(equalToConstant: 75),
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
            tableView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 20),
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
         if selectedCategories.contains(indexPath.row) {
             selectedCategories.remove(indexPath.row)
         } else {
             selectedCategories.insert(indexPath.row)
         }
         tableView.reloadRows(at: [indexPath], with: .automatic)
     }
 }
