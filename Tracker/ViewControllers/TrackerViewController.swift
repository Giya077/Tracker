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
    private var collectionView: UICollectionView!
    var stubView: UIImageView!
    var textLabel = UILabel()
    
    private var categories: [TrackerCategory] = [] {
          didSet {
              // При изменении данных в categories перезагружаем коллекцию или обновляем интерфейс
              if categories.isEmpty {
                  // Если categories пустой, показываем stubView
                  stubView.isHidden = false
                  collectionView.isHidden = true
              } else {
                  // Если categories не пустой, скрываем stubView и показываем collectionView
                  stubView.isHidden = true
                  collectionView.isHidden = false
                  collectionView.reloadData()
              }
          }
      }
    
    var completedTrackers: [TrackerRecord] = []
    
    weak var delegate: NewTrackerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlusButton()
        setupViews()
        setupUI()
        setupSearchBar()
        setupDatePicker()
        setupNavigationBar()
    }
    
    private func setupViews() {
        setupStubView()
        setupCollectionView()
        
        // Проверяем categories и обновляем интерфейс соответственно
        categories.isEmpty ? (stubView.isHidden = false) : (collectionView.isHidden = false)
    }
    
    private func setupStubView() {
        stubView = UIImageView(image: UIImage(named: "stubView"))
        stubView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stubView)
        
        NSLayoutConstraint.activate([
            stubView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stubView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupDatePicker() {
         datePicker = UIDatePicker()
         datePicker.preferredDatePickerStyle = .compact
         datePicker.datePickerMode = .date
         datePicker.locale = Locale(identifier: "ru_RU")
         datePicker.tintColor = .black
         datePicker.date = Date()
         datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
         datePicker.translatesAutoresizingMaskIntoConstraints = false
         view.addSubview(datePicker)
     }
    
    private func setupNavigationBar() {
        let datePickerBarButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerBarButton
        
        let plusNavButton = UIBarButtonItem(customView: plusButton)
        navigationItem.leftBarButtonItem = plusNavButton
    }
        
    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.layer.masksToBounds = true
        view.addSubview(searchBar)
        
        searchBar.searchTextField.backgroundColor = UIColor.lightGray
        searchBar.searchTextField.tintColor = .lightGray
        searchBar.backgroundImage = UIImage()
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.secondarySystemFill // Цвет фона текстового поля
            textField.textColor = .black
            textField.tintColor = .black
            textField.placeholder = "Поиск"
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
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        collectionView.backgroundColor = .lightGray
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: plusButton.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func addPlusButton() {
        plusButton = UIButton(type: .system)
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.tintColor = .black
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)
        
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
    }
    
    private func setupUI() {
        
        view.backgroundColor = .white
        
        // TRACKER LABEL
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerLabel)
        trackerLabel.textColor = .black
        trackerLabel.font = UIFont.boldSystemFont(ofSize: 34)
        trackerLabel.numberOfLines = 0
        trackerLabel.text = "Трекеры"
        
        NSLayoutConstraint.activate([
            trackerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        // TEXT LABEL
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
        textLabel.numberOfLines = 0
        textLabel.text = "Что будем отслеживать?"
        textLabel.textColor = .black
        textLabel.font = UIFont.systemFont(ofSize: 16)
        
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: stubView.bottomAnchor, constant: 20),
            textLabel.centerXAnchor.constraint(equalTo: stubView.centerXAnchor),
        ])
    }
    
    @objc
    private func didTapPlusButton() {
        let viewController = NewTrackerViewController()
        viewController.delegate = self
        let nav = UINavigationController(rootViewController: viewController)
        present(nav,animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: selectedDate)
        print("Выбранная дата: \(selectedDate). День недели: \(selectedDayOfWeek)")
        // Здесь добавьте логику для отображения трекеров привычек, соответствующих выбранному дню недели
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
        cell.backgroundColor = .black
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
