//
//  tracksView.swift
//  Tracker
//
//  Created by GiyaDev on 05.05.2024.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - Public Properties
    var habitTrackers: [Tracker] = []
    var eventTrackers: [Tracker] = []
    var completedTrackers: [TrackerRecord] = []
    var allCategories: [TrackerCategory] = []
    
    // MARK: - Private Properties
    private var trackerLabel = UILabel()
    private var plusButton = UIButton()
    private var searchBar = UISearchBar()
    private var datePicker = UIDatePicker()
    private var collectionView: UICollectionView!
    private let stubView = StubView(text: "Что будем отслеживать?")
    private var currentDate: Date = Date()
    private var searchText: String = ""
    
    private var trackerStore: TrackerStore
    private var trackerCategoryStore: TrackerCategoryStore
    private var trackers: [Tracker] = []

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
    
    // MARK: - Initializers
    init(trackerStore: TrackerStore, trackerCategoryStore: TrackerCategoryStore) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        super.init(nibName: nil, bundle: nil)
        self.trackerCategoryStore.trackerCategoryStoreDelegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlusButton()
        setupUI()
        setupViews()
        loadTrackers()
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(HeaderViewTrackerCollection.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderViewTrackerCollection")
        NotificationCenter.default.addObserver(self, selector: #selector(trackerCompletionChanged(_:)), name: .trackerCompletionChanged, object: nil)
    }
    
    private func loadTrackers() {
        let categoryCoreDataList = trackerCategoryStore.fetchAllCategories()
        var allCategories: [TrackerCategory] = []
        
        for categoryCoreData in categoryCoreDataList {
            if let categoryName = categoryCoreData.titles {
                var trackers: [Tracker] = []
                
                if let trackerCoreDataList = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] {
                    for trackerCoreData in trackerCoreDataList {
                        if let tracker = try? trackerStore.loadTrackerFromCoreData(from: trackerCoreData) {
                            trackers.append(tracker)
                        }
                    }
                }
                
                let trackerCategory = TrackerCategory(titles: categoryName, trackers: trackers)
                allCategories.append(trackerCategory)
            }
        }
        
        self.allCategories = allCategories
        filterTrackersByDate()
        collectionView.reloadData()
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
    
    private func updateStubViewVisibility() {
        if categories.isEmpty {
            stubView.isHidden = false
            collectionView.isHidden = true
        } else {
            stubView.isHidden = true
            collectionView.isHidden = false
        }
    }
        
    private func filterTrackersByDate() {
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        guard let selectedDay = Days(dayNumber: selectedDayOfWeek) else { return }

        var updatedCategories: [TrackerCategory] = []

        for category in allCategories {
            let filteredTrackers = category.trackers.filter { tracker in
                (tracker.schedule.isEmpty || tracker.schedule.contains(selectedDay)) &&
                (searchText.isEmpty || tracker.name.localizedCaseInsensitiveContains(searchText))
            }
            if !filteredTrackers.isEmpty {
                updatedCategories.append(TrackerCategory(titles: category.titles, trackers: filteredTrackers))
            }
        }

        categories = updatedCategories
        collectionView.reloadData()
        updateStubViewVisibility()
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
    
    func updateCategories() {
        self.categories = trackerCategoryStore.categories
        filterTrackersByDate()
        collectionView.reloadData()
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


extension TrackerViewController: NewTrackerDelegate {
    
    func didFinishCreatingTracker(trackerType: TrackerType) {
        print("Трекер типа \(trackerType) был создан.")
        // Обновите интерфейс или выполните другие необходимые действия
        loadTrackers()
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

extension TrackerViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.setTitle("Отменить", for: .normal)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.searchText = searchText
            filterTrackersByDate()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchText = ""
        filterTrackersByDate()
        searchBar.resignFirstResponder()
    }
}

extension TrackerViewController: TrackerCategoryStoreDelegate {
    func categoriesDidChange() {
        loadTrackers()
    }
    
    func categoryDidUpdate(_ category: TrackerCategory) {
        if let index = allCategories.firstIndex(where: { $0.titles == category.titles }) {
            allCategories[index] = category
        } else {
            allCategories.append(category)
        }
        filterTrackersByDate()
    }
}
