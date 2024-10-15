//
//  tracksView.swift
//  Tracker
//
//  Created by GiyaDev on 05.05.2024.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - Public Properties
    var completedTrackers: [TrackerRecord] = []
    var allCategories: [TrackerCategory] = []
    
    // MARK: - Private Properties
    private var trackerLabel = UILabel()
    private var plusButton = UIButton()
    private var filterButton: UIButton!
    private var searchBar = UISearchBar()
    private var datePicker = UIDatePicker()
    private var collectionView: UICollectionView!
    private let stubView = StubView(text: NSLocalizedString("What to track?", comment: "Что будем отслеживать?"))
    private var currentDate: Date = Date()
    private var currentFilter: TrackerFilter = .all
    private var searchText: String = ""
    private var pinnedTrackerIDs: [UUID] = []
    
    private var trackerStore: TrackerStore
    private var trackerCategoryStore: TrackerCategoryStore
    private var trackerRecordStore: TrackerRecordStore
    private var trackers: [Tracker] = []
    
    internal var categories: [TrackerCategory] = [] {
        didSet {
            print("Категории обновлены. Текущее количество категорий: \(categories.count)")
            if categories.isEmpty {
                stubView.isHidden = false
                collectionView.isHidden = true
            } else {
                stubView.isHidden = true
                collectionView.isHidden = false
                collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Initializers
    init(trackerStore: TrackerStore, trackerCategoryStore: TrackerCategoryStore, trackerRecordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
        self.trackerCategoryStore.trackerCategoryStoreDelegate = self
        
    }
    
    required init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPinnedTrackers()
        addPlusButton()
        setupUI()
        setupViews()
        addFilterButton()
        loadCompletedTrackers()
        loadTrackers()
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(HeaderViewTrackerCollection.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderViewTrackerCollection")
        NotificationCenter.default.addObserver(self, selector: #selector(trackerCompletionChanged(_:)), name: .trackerCompletionChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsService.shared.logEvent("open", parameters: [
            "screen": "Main"
        ])
        print("Отправлено событие: open, screen: Main")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AnalyticsService.shared.logEvent("close", parameters: [
            "screen": "Main"
        ])
        print("Отправлено событие: close, screen: Main")
    }
    
    private func loadTrackers() {
        let categoryCoreDataList = trackerCategoryStore.fetchAllCategories()
        var allCategories: [TrackerCategory] = []
        var pinnedTrackers: [Tracker] = []
        
        for categoryCoreData in categoryCoreDataList {
            if let categoryName = categoryCoreData.titles {
                var trackers: [Tracker] = []
                
                if let trackerCoreDataList = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] {
                    for trackerCoreData in trackerCoreDataList {
                        if let tracker = try? trackerStore.loadTrackerFromCoreData(from: trackerCoreData) {
                            if pinnedTrackerIDs.contains(tracker.id) {
                                pinnedTrackers.append(tracker)
                            } else {
                                trackers.append(tracker)
                            }
                        }
                    }
                }
                
                if !trackers.isEmpty {
                    let trackerCategory = TrackerCategory(titles: categoryName, trackers: trackers)
                    allCategories.append(trackerCategory)
                }
            }
        }
        
        if !pinnedTrackers.isEmpty {
            let pinnedCategory = TrackerCategory(titles: NSLocalizedString("Pinned", comment: "Закрепленные"), trackers: pinnedTrackers)
            allCategories.insert(pinnedCategory, at: 0)
            print("Pinned category created with \(pinnedTrackers.count) trackers.")
        }
        
        if pinnedTrackers.isEmpty && allCategories.isEmpty {
            pinnedTrackerIDs.removeAll()
            UserDefaults.standard.removeObject(forKey: "pinnedTrackers")
            print("No trackers found, cleared pinned trackers.")
        }
        
        self.allCategories = allCategories
        filterTrackersByDate()
        collectionView.reloadData()
    }
    
    private func loadPinnedTrackers() {
        if let savedPinnedTrackerIDs = UserDefaults.standard.array(forKey: "pinnedTrackers") as? [String] {
            pinnedTrackerIDs = savedPinnedTrackerIDs.compactMap { UUID(uuidString: $0) }
        } else {
            pinnedTrackerIDs = [] // Если нет данных в UserDefaults, создаем пустой массив
        }
        print("Loaded pinned trackers: \(pinnedTrackerIDs)")
    }
    
    private func savePinnedTrackers() {
        UserDefaults.standard.set(pinnedTrackerIDs.map { $0.uuidString }, forKey: "pinnedTrackers")
        print("Saved pinned trackers: \(pinnedTrackerIDs)")
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
        datePicker.tintColor = UIColor.label
        datePicker.date = Date()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        datePicker.setValue(ThemeManager.shared.textColor(), forKey: "textColor")
    }
    
    private func setupNavigationBar() {
        let datePickerBarButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerBarButton
        
        let plusNavButton = UIBarButtonItem(customView: plusButton)
        navigationItem.leftBarButtonItem = plusNavButton
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: view.topAnchor),
            plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            datePicker.topAnchor.constraint(equalTo: view.topAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
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
            textField.backgroundColor = Colors.systemSearchColor
            textField.textColor = ThemeManager.shared.textColor()
            textField.tintColor = ThemeManager.shared.textColor()
            
            let placeholderText = NSLocalizedString("Search", comment: "Поиск")
            let placeholderColor = UIColor.lightGray
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholderText,
                attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
            )
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
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addPlusButton() {
        plusButton = UIButton(type: .system)
        plusButton.setImage(UIImage(named: "plus"), for: .normal)
        plusButton.tintColor = ThemeManager.shared.textColor()
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusButton)
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.shared.backgroundColor()
        view.addSubview(trackerLabel)
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        trackerLabel.textColor = ThemeManager.shared.textColor()
        trackerLabel.font = UIFont.boldSystemFont(ofSize: 34)
        trackerLabel.numberOfLines = 0
        trackerLabel.text = NSLocalizedString("Trackers", comment: "Трекеры")
        
        NSLayoutConstraint.activate([
            trackerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    private func updateStubViewVisibility() {
        let hasTrackers = !categories.isEmpty
        stubView.isHidden = hasTrackers
        collectionView?.isHidden = !hasTrackers
        filterButton.isHidden = !hasTrackers && currentFilter == .all
    }

    private func filterTrackersByDate() {
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        guard let selectedDay = Days(dayNumber: selectedDayOfWeek) else { return }
        
        var updatedCategories: [TrackerCategory] = []
        
        for category in allCategories {
            let filteredTrackers = category.trackers.filter { tracker in
                let isScheduledForToday = tracker.schedule.isEmpty || tracker.schedule.contains(selectedDay)
                let isCompleted = completedTrackers.contains { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                let matchesSearchText = searchText.isEmpty || tracker.name.lowercased().hasPrefix(searchText.lowercased())
                
                var shouldInclude = false
                switch currentFilter {
                case .all:
                    shouldInclude = isScheduledForToday && matchesSearchText
                case .completed:
                    shouldInclude = isCompleted && matchesSearchText
                case .notCompleted:
                    shouldInclude = !isCompleted && isScheduledForToday && matchesSearchText
                case .today:
                    shouldInclude = isScheduledForToday && matchesSearchText && Calendar.current.isDate(currentDate, inSameDayAs: Date())
                }
                
                return shouldInclude
            }
            if !filteredTrackers.isEmpty {
                updatedCategories.append(TrackerCategory(titles: category.titles, trackers: filteredTrackers))
            }
        }
        
        categories = updatedCategories
        collectionView.reloadData()
        updateStubViewVisibility()
    }

    private func loadCompletedTrackers() {
        let records = trackerRecordStore.fetchAllRecords()
        completedTrackers = records.map { record in
            TrackerRecord(id: record.id!, date: record.date!)
        }
    }
    
    private func filterTrackersByState() {
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        guard let selectedDay = Days(dayNumber: selectedDayOfWeek) else { return }

        var filteredCategories: [TrackerCategory] = []

        for category in allCategories {
            var filteredTrackers: [Tracker] = []
            for tracker in category.trackers {
                let isCompleted = completedTrackers.contains { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                let isScheduledForToday = tracker.schedule.isEmpty || tracker.schedule.contains(selectedDay)
                let matchesSearchText = searchText.isEmpty || tracker.name.lowercased().hasPrefix(searchText.lowercased())

                var shouldInclude = false
                switch currentFilter {
                case .all:
                    shouldInclude = isScheduledForToday && matchesSearchText
                case .completed:
                    shouldInclude = isCompleted && matchesSearchText
                case .notCompleted:
                    shouldInclude = !isCompleted && isScheduledForToday && matchesSearchText
                case .today:
                    shouldInclude = isScheduledForToday && matchesSearchText && Calendar.current.isDate(currentDate, inSameDayAs: Date())
                }

                if shouldInclude {
                    filteredTrackers.append(tracker)
                }
            }

            if !filteredTrackers.isEmpty {
                filteredCategories.append(TrackerCategory(titles: category.titles, trackers: filteredTrackers))
            }
        }

        self.categories = filteredCategories
        collectionView.reloadData()
    }

    private func changeFilter(to newFilter: TrackerFilter) {
        currentFilter = newFilter
        
        if newFilter == .today {
            currentDate = Date()
            datePicker.date = currentDate
        }
    }

        
    private func addFilterButton() {
        filterButton = UIButton(type: .system)
        filterButton.setTitle(NSLocalizedString("Filters", comment: "Фильтры"), for: .normal)
        filterButton.tintColor = .white
        filterButton.backgroundColor = .systemBlue
        filterButton.layer.cornerRadius = 16
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(filterButton)
        filterButton.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)

        NSLayoutConstraint.activate([
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        view.bringSubviewToFront(filterButton)
    }
    
    private func showDeleteConfirmation(for tracker: Tracker, at indexPath: IndexPath) {
        let alertController = UIAlertController(
            title: NSLocalizedString("Удалить трекер", comment: "Заголовок алерта удаления трекера"),
            message: NSLocalizedString("Вы уверены, что хотите удалить трекер?", comment: "Сообщение алерта удаления трекера"),
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Отмена", comment: "Кнопка отмены"), style: .cancel, handler: nil)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("Удалить", comment: "Кнопка удаления"), style: .destructive) { [weak self] _ in
            self?.deleteTracker(tracker, at: indexPath)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc
    private func didTapFilterButton() {
        AnalyticsService.shared.logEvent("click", parameters: [
            "screen": "Main",
            "item": "filter"
        ])
        print("Отправлено событие: click, screen: Main, item: filter")
        
        let filterVC = FilterViewController(delegate: self, selectedFilter: currentFilter)
        filterVC.modalPresentationStyle = .automatic
        present(filterVC, animated: true, completion: nil)
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
            trackerRecordStore.saveCompletedTracker(trackerId: trackerId, date: currentDate)
            completedTrackers.append(TrackerRecord(id: trackerId, date: currentDate))
        } else {
            trackerRecordStore.deleteCompletedTracker(trackerId: trackerId, date: currentDate)
            if let index = completedTrackers.firstIndex(where: { $0.id == trackerId && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }) {
                completedTrackers.remove(at: index)
            }
        }

        filterTrackersByState()
    }
    
    @objc
    private func filterChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            changeFilter(to: .all)
        case 1:
            changeFilter(to: .completed)
        case 2:
            changeFilter(to: .notCompleted)
        default:
            break
        }
    }

    
    @objc
    private func didTapPlusButton() {
        AnalyticsService.shared.logEvent("click", parameters: [
            "screen": "Main",
            "item": "add_track"
        ])
        print("Отправлено событие: click, screen: Main, item: add_track")
        
        let viewController = NewTrackerViewController()
        viewController.delegate = self
        let nav = UINavigationController(rootViewController: viewController)
        present(nav, animated: true)
    }

    @objc
    private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        if currentFilter == .today && !Calendar.current.isDate(currentDate, inSameDayAs: Date()) {
            currentFilter = .all
            filterButton.tintColor = .white
        }
        filterTrackersByDate()
        filterTrackersByState()
    }

}

extension TrackerViewController: NewTrackerDelegate {
    
    func didFinishCreatingTracker(trackerType: TrackerType) {
        print("Трекер типа \(trackerType) был создан.")
        loadTrackers()
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = categories.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = categories[section].trackers.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Configuring cell at section \(indexPath.section), item \(indexPath.item)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCell
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        let completionCount = completedTrackers.filter { $0.id == tracker.id }.count
        let isCompleted = completedTrackers.contains { $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
        let isPinned = pinnedTrackerIDs.contains(tracker.id)
        cell.configure(with: tracker, isCompleted: isCompleted, completionCount: completionCount, currentDate: currentDate, isPinned: isPinned)
        print("Трекер: \(tracker.name), Количество завершений: \(completionCount), Завершен сегодня: \(isCompleted)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            return self.createContextMenu(for: tracker, at: indexPath)
        }
    }
    
    private func createContextMenu(for tracker: Tracker, at indexPath: IndexPath) -> UIMenu {
        let pinTitle = pinnedTrackerIDs.contains(tracker.id) ? NSLocalizedString("Unpin", comment: "Открепить") : NSLocalizedString("Pin", comment: "Закрепить")
        
        let pinAction = UIAction(title: pinTitle) { [weak self] _ in
            self?.togglePin(for: tracker)
        }
        
        let editAction = UIAction(title: NSLocalizedString("Edit", comment: "Редактировать")) { [weak self] _ in
            AnalyticsService.shared.logEvent("click", parameters: [
                "screen": "Main",
                "item": "edit"
            ])
            print("Отправлено событие: click, screen: Main, item: edit")
            
            self?.editTracker(tracker)
        }
        
        let deleteAction = UIAction(title: NSLocalizedString("Delete", comment: "Удалить"), attributes: .destructive) { [weak self] _ in
            AnalyticsService.shared.logEvent("click", parameters: [
                "screen": "Main",
                "item": "delete"
            ])
            print("Отправлено событие: click, screen: Main, item: delete")
            
            self?.showDeleteConfirmation(for: tracker, at: indexPath)
        }
        
        return UIMenu(children: [pinAction, editAction, deleteAction])
    }

    
    private func togglePin(for tracker: Tracker) {
        loadPinnedTrackers()
        if let index = pinnedTrackerIDs.firstIndex(of: tracker.id) {
            pinnedTrackerIDs.remove(at: index)
            print("Unpinned tracker with ID: \(tracker.id)")
        } else {
            pinnedTrackerIDs.append(tracker.id)
            print("Pinned tracker with ID: \(tracker.id)")
        }
    
        savePinnedTrackers()
        loadTrackers()
    }

    private func editTracker(_ tracker: Tracker) {
        if isHabit(tracker) {
            let habitVC = HabitViewController(trackerCategoryStore: trackerCategoryStore)
            habitVC.trackerType = .habit
            habitVC.isEditingTracker = true
            habitVC.configureForEditing(tracker)
            habitVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(habitVC, animated: true)
        } else if isEvent(tracker) {
            let eventVC = IrregularEventViewController(trackerCategoryStore: trackerCategoryStore)
            eventVC.trackerType = .event
            eventVC.isEditingTracker = true
            eventVC.configureForEditing(tracker)
            eventVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(eventVC, animated: true)
        }
    }
    
    private func isHabit(_ tracker: Tracker) -> Bool {
        return !tracker.schedule.isEmpty
    }
    
    private func isEvent(_ tracker: Tracker) -> Bool {
        return tracker.schedule.isEmpty
    }
    
    private func deleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        do {
            try trackerStore.deleteTracker(with: tracker.id)
            if let pinnedIndex = pinnedTrackerIDs.firstIndex(of: tracker.id) {
                pinnedTrackerIDs.remove(at: pinnedIndex)
                UserDefaults.standard.set(pinnedTrackerIDs.map { $0.uuidString }, forKey: "pinnedTrackers")
                print("Removed pinned tracker with ID: \(tracker.id)")
            }
            
            loadTrackers()
        } catch {
            print("Failed to delete tracker: \(error)")
        }
    }
    
    private func pinTracker(_ tracker: Tracker) {
        var pinnedCategory = allCategories.first { $0.titles == "Pinned" }
        if pinnedCategory == nil {
            pinnedCategory = TrackerCategory(titles: "Pinned", trackers: [])
            allCategories.append(pinnedCategory!)
        }
        if !pinnedTrackerIDs.contains(tracker.id) {
            var updatedTrackers = pinnedCategory?.trackers ?? []
            updatedTrackers.append(tracker)
            let updatedCategory = TrackerCategory(titles: pinnedCategory!.titles, trackers: updatedTrackers)
            if let index = allCategories.firstIndex(where: { $0.titles == "Pinned" }) {
                allCategories[index] = updatedCategory
            }
            pinnedTrackerIDs.append(tracker.id)
            trackerCategoryStore.saveTracker(tracker, forCategoryTitle: "Pinned")
            loadTrackers()
        }
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
            cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Отменить"), for: .normal)
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

extension TrackerViewController: FilterDelegate {
    func didSelectFilter(_ filter: TrackerFilter) {
        changeFilter(to: filter)
        
        if filter == .all {
            filterButton.tintColor = .white
        } else {
            filterButton.tintColor = .red
        }
        
        filterTrackersByDate()
        filterTrackersByState()
        dismiss(animated: true, completion: nil)
    }
}
