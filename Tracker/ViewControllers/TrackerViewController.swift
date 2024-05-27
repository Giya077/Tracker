//
//  tracksView.swift
//  Tracker
//
//  Created by GiyaDev on 05.05.2024.
//

import UIKit

final class TrackerViewController: UIViewController, UISearchBarDelegate, HabitCreationDelegate, NewTrackerDelegate {
    
    weak var delegate: HabitCreationDelegate?
    
    private var trackerLabel = UILabel()
    private var plusButton = UIButton()
    private var searchBar: UISearchBar!
    private var datePicker = UIDatePicker()
    private var collectionView: UICollectionView!
    private let stubView = StubView(text: "Что будем отслеживать?")
    
    var trackers: [Tracker] = []
    var completedTrackers: [TrackerRecord] = []
    
    internal var categories: [TrackerCategory] = [] {
        didSet {
            print("Категории обновлены. Текущее количество категорий: \(categories.count)")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlusButton()
        setupUI()
        setupViews()
//        setupSearchBar()
//        setupDatePicker()
//        setupNavigationBar()
        delegate = self
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        NotificationCenter.default.addObserver(self, selector: #selector(trackerCompletionChanged(_:)), name: .trackerCompletionChanged, object: nil)
    }
    
    
    private func setupTrackerCell() {
        // Настройте ограничения и стили для nameLabel и daysLabel внутри TrackerCell
    }

    private func setupHeaderView() {
        // Настройте ограничения и стили для titleLabel внутри HeaderView
    }
    
    private func setupViews() {
        setupStubView()
        setupSearchBar()
        setupCollectionView()
        setupDatePicker()
        setupNavigationBar()
        
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
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
    private func trackerCompletionChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let trackerId = userInfo["trackerId"] as? UUID,
              let isCompleted = userInfo["isCompleted"] as? Bool else { return }
        
        if isCompleted {
            let trackerRecord = TrackerRecord(id: trackerId, date: Date())
            completedTrackers.append(trackerRecord)
        } else {
            if let index = completedTrackers.firstIndex(where: { $0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: Date()) }) {
                completedTrackers.remove(at: index)
            }
        }
        
        collectionView.reloadData()
    }
    
    @objc
    private func didTapPlusButton() {
        let viewController = NewTrackerViewController()
        viewController.delegate = self
        let nav = UINavigationController(rootViewController: viewController)
        present(nav,animated: true)
    }
    
    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
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
    
    func didAddTracker(_ tracker: Tracker?) {
        // Проверяем, что трекер не nil
        guard let newTracker = tracker else {
            print("Ошибка: Новый трекер не был передан.")
            return
        }
        
        // Логика для добавления нового трекера в соответствующую категорию
        if let categoryTitle = newTracker.categoryTitle {
            if let index = categories.firstIndex(where: { $0.titles == categoryTitle }) {
                categories[index].trackers.append(newTracker)
                print("Новый трекер добавлен в категорию: \(categoryTitle)")
            } else {
                // Создаем новую категорию, если не найдена
                let newCategory = TrackerCategory(titles: categoryTitle, trackers: [newTracker])
                categories.append(newCategory)
                print("Создана новая категория: \(categoryTitle) и добавлен трекер")
            }
        } else {
            // Если трекер не содержит информацию о категории, добавляем его в первую категорию (если она существует)
            if !categories.isEmpty {
                categories[0].trackers.append(newTracker)
                print("Новый трекер добавлен в категорию: \(categories[0].titles)")
            } else {
                print("Ошибка: Категории не инициализированы или отсутствуют.")
            }
        }
        
        // Обновляем коллекцию
        collectionView.reloadData()
        dismiss(animated: true)
    }
    
    func didCreateTracker(name: String, category: TrackerCategory, schedule: [Days]) {
        print("Метод didCreateTracker вызван")
        print("Создание трекера с именем: \(name) в категории: \(category.titles)")
        
        let newTracker = Tracker(id: UUID(), name: name, schedule: schedule, categoryTitle: category.titles)
        
        if let index = categories.firstIndex(where: { $0.titles == category.titles }) {
            categories[index].trackers.append(newTracker)
            print("Трекер добавлен в существующую категорию: \(category.titles)")
        } else {
            // Добавляем новую категорию, если она не найдена
            let newCategory = TrackerCategory(titles: category.titles, trackers: [newTracker])
            categories.append(newCategory)
            print("Создана новая категория: \(category.titles) и добавлен трекер")
        }
        
        print("Текущее количество категорий: \(categories.count)")
        collectionView.reloadData()
    }
    
    
    func didCreateTrackerSuccessfully(_ tracker: Tracker) {
        print("Новый трекер успешно создан:")
        print("ID: \(tracker.id)")
        print("Название: \(tracker.name)")
        print("Расписание: \(tracker.schedule)")
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = categories.count
        print("Number of sections: \(count)")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = categories[section].trackers.count
        print("Number of items in section \(section): \(count)")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Configuring cell at section \(indexPath.section), item \(indexPath.item)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        let completionCount = completedTrackers.filter { $0.id == tracker.id }.count
        let isCompleted = completedTrackers.contains { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: Date()) }
        cell.configure(with: tracker, isCompleted: isCompleted, completionCount: completionCount)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
        header.titleLabel.text = categories[indexPath.section].titles
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}
