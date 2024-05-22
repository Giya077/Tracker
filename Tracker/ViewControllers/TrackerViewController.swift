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
    private let stubView = StubView(text: "Что будем отслеживать?")
    
    
    internal var categories: [TrackerCategory] = [] {
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
        
        // Проверяем categories и обновляем интерфейс
        categories.isEmpty ? (stubView.isHidden = false) : (collectionView.isHidden = false)
    }
    
    private func setupStubView() {
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
        searchBar.backgroundImage = UIImage()

        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = Colors.systemSearchColor // Цвет фона текстового поля
            textField.textColor = .black
            textField.tintColor = .black
            
            // Установка цвета текста плейсхолдера
            let placeholderText = "Поиск"
            let placeholderColor = UIColor.lightGray // Цвет плейсхолдера
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
            )
            // Настройка значка лупы
            if let leftView = textField.leftView as? UIImageView {
                leftView.tintColor = .lightGray // Установка цвета значка лупы
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
            }
        }

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: trackerLabel.topAnchor, constant: 50),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.1) {
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
        // Здесь добавить логику для отображения трекеров привычек, соответствующих выбранному дню недели
    }
    
    func addTrackerToCompleted(trackRecord: TrackerRecord) {
        completedTrackers.append(trackRecord) /// скорее в в трекерес
    }
    
    func removeTrackerFromCompleted(trackRecord: TrackerRecord) {
        if let index = completedTrackers.firstIndex(where: { $0.id == trackRecord.id}) {
            completedTrackers.remove(at: index)
        }
    }
    
    func didAddTracker(_ tracker: Tracker) {
        // Логика для добавления нового трекера в соответствующую категорию
        // например:
        // categories[0].trackers.append(tracker) !!!!!!!!!!!!!!!!!!!!!!!!!!!!
//        collectionView.reloadData()
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
//        Получаем выбранную категорию
//        Создаем новый массив трекеров для обновленной категории
//        let newTracker = Tracker(id: UUID(), name: "Новый трекер", color: .systemPink, emoji: "🚀", schedule: [.everyday])
//        let updatedTrackers = selectedCategory.trackers + [newTracker]
//        
//        // Создаем обновленную категорию с новым массивом трекеров
//        let updatedCategory = TrackerCategory(titles: selectedCategory.titles, trackers: updatedTrackers)
//        
//        // Создаем новый массив категорий с обновленной категорией на выбранной позиции
//        var updatedCategories = categories
//        updatedCategories[indexPath.item] = updatedCategory
//        
//        // Присваиваем обновленный массив категорий переменной categories
//        categories = updatedCategories
//        
//        // Перезагружаем коллекцию после изменения данных
//        collectionView.reloadData()
    }
}
