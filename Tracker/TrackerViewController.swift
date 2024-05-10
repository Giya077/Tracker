//
//  tracksView.swift
//  Tracker
//
//  Created by GiyaDev on 05.05.2024.
//

import UIKit

final class TrackerViewController: UIViewController, UISearchBarDelegate {
    
    private var trackerLabel = UILabel()
    private var plusButton = UIButton()
    private var dateLabel = UILabel()
    private var searchBar: UISearchBar!
    var imageView = UIImage(named: "error")
    var textLabel = UILabel()
    
    private lazy var dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlusButton()
        setupUI()
        setupSearchBar()
    }
    
    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.layer.masksToBounds = true
        view.addSubview(searchBar)
        
        searchBar.tintColor = .lightGray
        searchBar.searchTextField.backgroundColor = .lightGray
        searchBar.searchTextField.textColor = .lightGray
        searchBar.tintColor = .white // cancel color
        searchBar.searchTextField.tintColor = .lightGray
        searchBar.backgroundImage = UIImage()
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .lightGray // Цвет фона текстового поля
            textField.textColor = .white // Цвет текста
        }
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: trackerLabel.topAnchor, constant: 50),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) {
            searchBar.showsCancelButton = true
            searchBar.layoutIfNeeded()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.8) {
            searchBar.showsCancelButton = false // Скрываем кнопку "Отмена" при нажатии на неё
            searchBar.text = "" // Очищаем текст в поисковом поле
            searchBar.resignFirstResponder() // Скрываем клавиатуру
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // TRACKER LABEL
        view.backgroundColor = .black
        
        // TRACKER LABEL
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerLabel)
        trackerLabel.textColor = .white
        trackerLabel.font = UIFont.boldSystemFont(ofSize: 34)
        trackerLabel.numberOfLines = 0
        trackerLabel.text = "Трекеры"
        
        NSLayoutConstraint.activate([
            trackerLabel.topAnchor.constraint(equalTo: plusButton.topAnchor, constant: 30),
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        // DATE LABEL
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateLabel)
        dateLabel.textColor = .black
        dateLabel.text = dateFormatter.string(from: Date())
        dateLabel.numberOfLines = 0
        dateLabel.backgroundColor = .white
        dateLabel.layer.cornerRadius = 4
        dateLabel.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            dateLabel.centerYAnchor.constraint(equalTo: trackerLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // IMAGE
        let starImage = UIImageView(image: imageView)
        view.addSubview(starImage)
        starImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            starImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            starImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // TEXT LABEL
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
        textLabel.numberOfLines = 0
        textLabel.text = "Что будем отслеживать?"
        textLabel.textColor = .white
        textLabel.font = UIFont.systemFont(ofSize: 16)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: starImage.bottomAnchor, constant: 20),
            textLabel.centerXAnchor.constraint(equalTo: starImage.centerXAnchor),
        ])
    }
    
    private func addPlusButton() {
         plusButton = UIButton.systemButton(
            with: UIImage(systemName: "plus")!,
            target: self,
            action: #selector(self.didTapPlusButton))
        
        plusButton.tintColor = .white
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
        plusButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
        plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30)
        ])
                                    
    }
    
    @objc
    private func didTapPlusButton() {
        // do something
    }
}
