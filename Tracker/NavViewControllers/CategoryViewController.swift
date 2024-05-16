//
//  CategoryViewController.swift
//  Tracker
//
//  Created by GiyaDev on 14.05.2024.
//

import Foundation
import UIKit

class CategoryViewController: UIViewController {
    
    private let categoryLabel: UILabel = {
        let categoryLabel = UILabel()
        categoryLabel.text = "Категория"
        categoryLabel.textColor = .black
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 20)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        return categoryLabel
    }()
    
    private let addCategoryButton: UIButton = {
        let addCategoryButton = UIButton(type: .system)
        addCategoryButton.setTitle("Добавить категорию", for: .normal)
        addCategoryButton.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        addCategoryButton.backgroundColor = .black
        addCategoryButton.tintColor = .white
        addCategoryButton.layer.cornerRadius = 10
        addCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        addCategoryButton.layer.shadowColor = UIColor.black.cgColor
        addCategoryButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addCategoryButton.layer.shadowOpacity = 0.5
        addCategoryButton.layer.shadowRadius = 4
        
        return addCategoryButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
    
    @objc
    private func addCategoryButtonTapped() {
        
    }
}
