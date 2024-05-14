//
//  tracksView.swift
//  Tracker
//
//  Created by GiyaDev on 05.05.2024.
//

import UIKit

final class TrackerViewController: UIViewController, UISearchBarDelegate, NewTrackerDelegate {
    
    private var trackerLabel = UILabel()
    private var plusButton = UIButton()
    private var searchBar: UISearchBar!
    private var datePicker = UIDatePicker()
    var imageView = UIImage(named: "error")
    var textLabel = UILabel()
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    weak var delegate: NewTrackerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlusButton()
        setupUI()
        setupSearchBar()
        setupDatePicker()
        setupNavigationBar()
    }
    
    private func setupDatePicker() {
         datePicker = UIDatePicker()
         datePicker.preferredDatePickerStyle = .compact
         datePicker.datePickerMode = .date
         datePicker.locale = Locale(identifier: "ru_RU")
         datePicker.tintColor = .systemBlue
         datePicker.date = Date()
         datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
         datePicker.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(datePicker)
         
         NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: trackerLabel.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
         ])
     }
    
    private func setupNavigationBar() {
        let datePickerBarButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerBarButton
        
        let plusNavButton = UIBarButtonItem(customView: plusButton)
        navigationItem.leftBarButtonItem = plusNavButton
        
    }
    
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: selectedDate) // Получаем день недели
        print("Выбранная дата: \(selectedDate). День недели: \(selectedDayOfWeek)")
        // Здесь добавьте логику для отображения трекеров привычек, соответствующих выбранному дню недели
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
        searchBar.searchTextField.backgroundColor = UIColor.systemGray6
        searchBar.searchTextField.textColor = .gray
        searchBar.tintColor = .white // cancel color
        searchBar.searchTextField.tintColor = .lightGray
        searchBar.backgroundImage = UIImage()
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.systemGray6 // Цвет фона текстового поля
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
    
    private var collectionView: UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: plusButton.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return collectionView
    }
    
    private func setupUI() {
        
        view.backgroundColor = .black
        
        // TRACKER LABEL
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerLabel)
        trackerLabel.textColor = .white
        trackerLabel.font = UIFont.boldSystemFont(ofSize: 34)
        trackerLabel.numberOfLines = 0
        trackerLabel.text = "Трекеры"
        
        NSLayoutConstraint.activate([
            trackerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
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
        plusButton = UIButton(type: .system)
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.tintColor = .white
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)
        
//        NSLayoutConstraint.activate([
//            plusButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
//            plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
//        ])
        
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
    }
    
    @objc
    private func didTapPlusButton() {
        let viewController = NewTrackerViewController()
        viewController.delegate = self
        let nav = UINavigationController(rootViewController: viewController)
        present(nav,animated: true)
    }
    
    func addTrackerToCompleted(trackRecord: TrackerRecord) {
        completedTrackers.append(trackRecord)
    }
    
    func removeTrackerFromCompleted(trackRecord: TrackerRecord) {
        if let index = completedTrackers.firstIndex(where: { $0.id == trackRecord.id}) {
            completedTrackers.remove(at: index)
        }
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath)
        cell.backgroundColor = .white
        // Настройте ячейку здесь, например, установите заголовок из categories[indexPath.item].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Получаем выбранную категорию
        let selectedCategory = categories[indexPath.item]
        
        // Создаем новый массив трекеров для обновленной категории
        let newTracker = Tracker(id: UUID(), name: "Новый трекер", color: .systemPink, emoji: "🚀", schedule: [.everyday])
        let updatedTrackers = selectedCategory.trackers + [newTracker]
        
        // Создаем обновленную категорию с новым массивом трекеров
        let updatedCategory = TrackerCategory(titles: selectedCategory.titles, trackers: updatedTrackers)
        
        // Создаем новый массив категорий с обновленной категорией на выбранной позиции
        var updatedCategories = categories
        updatedCategories[indexPath.item] = updatedCategory
        
        // Присваиваем обновленный массив категорий переменной categories
        categories = updatedCategories
        
        // Перезагружаем коллекцию после изменения данных
        collectionView.reloadData()
    }
}
