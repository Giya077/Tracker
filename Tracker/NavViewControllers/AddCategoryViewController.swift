//
//  AddCategoryViewController.swift
//  Tracker
//
//  Created by GiyaDev on 20.05.2024.
//


import Foundation
import UIKit

class AddCategoryViewController: UIViewController {
    
    weak var delegate: NewCategoryViewControllerDelegate?
    
    private let label: UILabel = {
        let label = BasicTextLabel(text: "Новая категория")
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let doneButton = BasicButton(title: "Готово")
        doneButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        return doneButton
    }()
    
    private lazy var categoryNameTextField: UITextField = {
        let categoryNameTextField = UITextField()
        categoryNameTextField.textColor = .black
        categoryNameTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        categoryNameTextField.layer.cornerRadius = 16
        categoryNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: categoryNameTextField.frame.height))
        categoryNameTextField.leftViewMode = .always
        categoryNameTextField.font = UIFont.systemFont(ofSize: 18)
        categoryNameTextField.attributedPlaceholder = NSAttributedString(string: "Введите название категории", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        categoryNameTextField.translatesAutoresizingMaskIntoConstraints = false
        return categoryNameTextField
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        categoryNameTextField.delegate = self
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(label)
        view.addSubview(doneButton)
        view.addSubview(categoryNameTextField)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            categoryNameTextField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 50),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 100),
            
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    @objc private func addCategory() {
        guard let name = categoryNameTextField.text, !name.isEmpty else { return }
        let newCategory = TrackerCategory(titles: name, trackers: []) // Используем инициализатор с передачей только названия
        delegate?.didAddCategory(newCategory)
//        delegate?.removeStubAndShowCategories()
        dismiss(animated: true)
    }
}

extension AddCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Скрыть клавиатуру
        return true
    }
}
