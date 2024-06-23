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
    
    var habitTrackers: [Tracker] = []
    var eventTrackers: [Tracker] = []
    var completedTrackers: [TrackerRecord] = []
    
    var currentDate: Date = Date()
    
    var allCategories: [TrackerCategory] = []  // Для хранения всех категорий без фильтрации
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
        
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(HeaderViewTrackerCollection.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderViewTrackerCollection")
        
        NotificationCenter.default.addObserver(self, selector: #selector(trackerCompletionChanged(_:)), name: .trackerCompletionChanged, object: nil)
    }
    
    private func setupViews() {
        setupStubView()
        setupSearchBar()
        setupCollectionView()
        setupDatePicker()
        setupNavigationBar()
        
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
        
        // Установка цвета текста
        datePicker.setValue(UIColor.black, forKey: "textColor")
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
            
            let placeholderText = "Поиск"
            let placeholderColor = UIColor.lightGray
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
            )
            // Настройка значка лупы
            if let leftView = textField.leftView as? UIImageView {
                leftView.tintColor = .lightGray
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
        UIView.animate(withDuration: 0.3) {
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
        collectionView.register(HeaderViewTrackerCollection.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderViewTrackerCollection")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addPlusButton() {
        plusButton = UIButton(type: .system)
        plusButton.setImage(UIImage(named: "plus"), for: .normal)
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
    
    private func filterTrackersByDate() {
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        guard let selectedDay = Days(dayNumber: selectedDayOfWeek) else { return }

        var updatedCategories: [TrackerCategory] = []

        for category in allCategories {
            let filteredTrackers = category.trackers.filter { tracker in
                return tracker.schedule.contains(selectedDay)
            }
            if !filteredTrackers.isEmpty {
                updatedCategories.append(TrackerCategory(titles: category.titles, trackers: filteredTrackers))
            }
        }

        print("Количество отфильтрованных категорий: \(updatedCategories.count)")
        updatedCategories.forEach { category in
            print("Категория: \(category.titles), Количество трекеров: \(category.trackers.count)")
        }

        categories = updatedCategories
        collectionView.reloadData()
    }

    @objc
    private func trackerCompletionChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let trackerId = userInfo["trackerId"] as? UUID,
              let isCompleted = userInfo["isCompleted"] as? Bool else { return }

        let today = Calendar.current.startOfDay(for: Date())
        let selectedDay = Calendar.current.startOfDay(for: currentDate)

        if selectedDay > today {
            print("Нельзя отмечать трекеры для будущих дат.")
            return
        }

        if isCompleted {
            let trackerRecord = TrackerRecord(id: trackerId, date: currentDate)
            completedTrackers.append(trackerRecord)
        } else {
            if let index = completedTrackers.firstIndex(where: { $0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }) {
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
        currentDate = sender.date
        filterTrackersByDate()
        print("Выбранная дата: \(currentDate)")
    }
    
    func addTrackerToCompleted(trackRecord: TrackerRecord) {
        completedTrackers.append(trackRecord)
    }
    
    func removeTrackerFromCompleted(trackRecord: TrackerRecord) {
        if let index = completedTrackers.firstIndex(where: { $0.id == trackRecord.id}) {
            completedTrackers.remove(at: index)
        }
    }
    
    func didAddTracker(_ tracker: Tracker, to category: TrackerCategory, trackerType: TrackerType) {
        if let index = allCategories.firstIndex(where: { $0.titles == category.titles }) {
            var category = allCategories[index]
            var trackers = category.trackers
            trackers.append(tracker)
            allCategories[index] = TrackerCategory(titles: category.titles, trackers: trackers)
        } else {
            let newCategory = TrackerCategory(titles: category.titles, trackers: [tracker])
            allCategories.append(newCategory)
        }

        if trackerType == .habit {
            habitTrackers.append(tracker)
        } else if trackerType == .event {
            eventTrackers.append(tracker)
        }

        printTrackersCount()
        filterTrackersByDate()
        collectionView.reloadData()
        dismiss(animated: true)

        print("Трекер добавлен. Текущее количество категорий: \(allCategories.count)")
        allCategories.forEach { category in
            print("Категория: \(category.titles), Количество трекеров: \(category.trackers.count)")
        }
    }
    
    func didCreateTrackerSuccessfully(_ tracker: Tracker) {
        print("Новый трекер успешно создан:")
        print("ID: \(tracker.id)")  
        print("Название: \(tracker.name)")
        print("Расписание: \(tracker.schedule)")
    }
        
    func printTrackersCount() {
        print("Количество привычек: \(habitTrackers.count)")
        print("Количество нерегулярных событий: \(eventTrackers.count)")
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
        let isCompleted = completedTrackers.contains { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
        cell.configure(with: tracker, isCompleted: isCompleted, completionCount: completionCount)
        print("Трекер: \(tracker.name), Количество завершений: \(completionCount), Завершен сегодня: \(isCompleted)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderViewTrackerCollection", for: indexPath) as! HeaderViewTrackerCollection
        header.titleLabel.text = categories[indexPath.section].titles
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let itemsPerRow: CGFloat = 2
        let totalPadding: CGFloat = padding * (itemsPerRow - 1)
        let itemWidth: CGFloat = (collectionView.frame.width - totalPadding) / itemsPerRow
        let itemHeight: CGFloat = 150
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
