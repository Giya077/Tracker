//
//  HabitViewController.swift
//  Tracker
//
//  Created by GiyaDev on 14.05.2024.
//

import UIKit

final class HabitViewController: UIViewController {
    
    // MARK: - Public Properties
    var trackerType: TrackerType?
    weak var trackerDelegate: NewTrackerDelegate?
    var isEditingTracker: Bool = false
    var trackerBeingEdited: Tracker?
    var existingTracker: Tracker?
    
    // MARK: - Private Properties
    private var categoryViewController: CategoryViewController?
    private var trackerCategoryStore: TrackerCategoryStore
    private var selectedDays: Set<Days> = []
    private var selectedCategory: TrackerCategory?
    
    private var selectedColor: UIColor?
    private var selectedEmoji: String?
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    
    private let label: UILabel = {
        let label = BasicTextLabel(text: NSLocalizedString("New habit", comment: "Новая привычка"))
        return label
    }()
    
    private let trackNaming: UITextField = {
        let trackNaming = UITextField()
        trackNaming.textColor = ThemeManager.shared.textColor()
        trackNaming.backgroundColor = Colors.systemSearchColor
        trackNaming.layer.cornerRadius = 16
        trackNaming.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: trackNaming.frame.height))
        trackNaming.leftViewMode = .always
        trackNaming.font = UIFont.systemFont(ofSize: 18)
        trackNaming.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Enter tracker name", comment: "Введите название трекера"), attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        trackNaming.translatesAutoresizingMaskIntoConstraints = false
        return trackNaming
    }()
    
    private let characterLimitLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Character limit: 38", comment: "Ограничение 38 символов")
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrayCells = [
        NSLocalizedString("Category", comment: "Категория"),
        NSLocalizedString("Schedule", comment: "Расписание")
    ]
    
    private let cellIdentifier = "CellType1"
    private lazy var categoryAndScheduleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CellType1.self, forCellWithReuseIdentifier: "CellType1")
        return collectionView
    }()
    
    private let contrainerView: UIView = {
        let contrainerView = UIView()
        contrainerView.backgroundColor = Colors.systemSearchColor
        contrainerView.layer.cornerRadius = 10
        contrainerView.layer.masksToBounds = true
        contrainerView.translatesAutoresizingMaskIntoConstraints = false
        return contrainerView
    }()
    
    private let separatorLine: UIView = {
        let separatorLine = UIView()
        separatorLine.backgroundColor = .lightGray
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        return separatorLine
    }()
    
    private let emojiHeaderLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeManager.shared.textColor()
        label.text = NSLocalizedString("Emoji", comment: "Emoji")
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let colorsHeaderLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeManager.shared.textColor()
        label.text = NSLocalizedString("Color", comment: "Цвет")
        label.font = UIFont.boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiArray = ["😊", "🚀", "🎉", "⭐️", "🧨", "🎈", "🍀", "🌺", "🥷", "👩‍🚀", "🏊‍♀️", "🐻", "👩‍🚀", "🍔", "🍕", "🎺", "🎸", "📚"]
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        return collectionView
    }()
    
    private let colorArray: [UIColor] = [.sLightPurple, .sfBlue, .sfCaesarPurple, .sfChampagne, .sfDarkPurple, .sfFial, .sfGreen, .sfGreenLawn, .sfLightPink, .sfOceanBlue, .sfOrange, .sfPamelaOrange, .sfPink, .sfPinkyPink, .sfPurple, .sfRed, .sfSystemPurple, .sfTiffany]
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Отменить"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.backgroundColor = ThemeManager.shared.backgroundColor()
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.layer.masksToBounds = true
        cancelButton.tintColor = .red
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return cancelButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = UIButton(type: .system)
        createButton.setTitle(NSLocalizedString("Create", comment: "Создать"), for: .normal)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        createButton.layer.cornerRadius = 16
        createButton.layer.masksToBounds = true
        createButton.tintColor = .white
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        createButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return createButton
    }()
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.backgroundColor()
        navigationItem.hidesBackButton = true
        setupScrollView()
        setupView()
        
        let categoryViewModel = CategoryViewModel(trackerCategoryStore: trackerCategoryStore)
        categoryViewController = CategoryViewController(viewModel: categoryViewModel)
        
        categoryViewController?.onCategorySelected = { [weak self] category in
            self?.selectedCategory = category
            self?.updateCategoryLabel()
            self?.updateCreateButtonState()
        }
        
        categoryAndScheduleCollectionView.delegate = self
        categoryAndScheduleCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        trackNaming.delegate = self
        
        createButton.isEnabled = false
        createButton.backgroundColor = .lightGray
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedCategory = selectedCategory {
            if let updatedCategory = trackerCategoryStore.categories.first(where: { $0.titles == selectedCategory.titles }) {
                self.selectedCategory = updatedCategory
            } else {
                self.selectedCategory = nil
            }
        }
        
        updateTrackerLabel(label, isEditingTracker: isEditingTracker, trackerType: trackerType)
        updateCategoryLabel()
        updateCreateButtonState()
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    private func setupView() {
        
        contentView.addSubview(label)
        contentView.addSubview(trackNaming)
        contentView.addSubview(contrainerView)
        contentView.addSubview(separatorLine)
        contentView.addSubview(categoryAndScheduleCollectionView)
        contentView.addSubview(emojiHeaderLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorsHeaderLabel)
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(characterLimitLabel)
        
        let buttonStack = stackViewButton()
        contentView.addSubview(buttonStack)
        
        hideCharacterLimitLabel()
        
        NSLayoutConstraint.activate([
            
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            trackNaming.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
            trackNaming.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            trackNaming.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            trackNaming.heightAnchor.constraint(equalToConstant: 75),
            
            characterLimitLabel.topAnchor.constraint(equalTo: trackNaming.bottomAnchor, constant: 5),
            characterLimitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            categoryAndScheduleCollectionView.topAnchor.constraint(equalTo: characterLimitLabel.bottomAnchor, constant: 10),
            categoryAndScheduleCollectionView.leadingAnchor.constraint(equalTo: trackNaming.leadingAnchor),
            categoryAndScheduleCollectionView.trailingAnchor.constraint(equalTo: trackNaming.trailingAnchor),
            categoryAndScheduleCollectionView.heightAnchor.constraint(equalToConstant: 150),
            
            contrainerView.topAnchor.constraint(equalTo: categoryAndScheduleCollectionView.topAnchor),
            contrainerView.leadingAnchor.constraint(equalTo: categoryAndScheduleCollectionView.leadingAnchor),
            contrainerView.trailingAnchor.constraint(equalTo: categoryAndScheduleCollectionView.trailingAnchor),
            contrainerView.heightAnchor.constraint(equalToConstant: 150),
            
            separatorLine.leadingAnchor.constraint(equalTo: contrainerView.leadingAnchor, constant: 20),
            separatorLine.trailingAnchor.constraint(equalTo: contrainerView.trailingAnchor, constant: -20),
            separatorLine.centerYAnchor.constraint(equalTo: contrainerView.centerYAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            //EmojiCollectionvView
            
            emojiHeaderLabel.topAnchor.constraint(equalTo: contrainerView.bottomAnchor, constant: 15),
            emojiHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiHeaderLabel.bottomAnchor, constant: 10),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 130),
            
            colorsHeaderLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 10),
            colorsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            //ColorCollectionvView
            
            colorCollectionView.topAnchor.constraint(equalTo: colorsHeaderLabel.bottomAnchor, constant: 25),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 160),
            
            buttonStack.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func stackViewButton() -> UIStackView {
        let stackViewButton = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackViewButton.axis = .horizontal
        stackViewButton.spacing = 15
        stackViewButton.distribution = .fillEqually
        stackViewButton.alignment = .fill
        stackViewButton.translatesAutoresizingMaskIntoConstraints = false
        return stackViewButton
    }
    
    private func updateCategoryLabel() {
        guard let categoryCell = categoryAndScheduleCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? CellType1 else { return }
        let categoriesText = selectedCategory?.titles ?? ""
        categoryCell.configure(title: NSLocalizedString("Category", comment: "Категория"), days: categoriesText.isEmpty ? nil : categoriesText)
        print("Selected category: \(selectedCategory?.titles ?? "No Category")")
    }
    
    private func checkFields() -> Bool {
        guard let name = trackNaming.text, !name.isEmpty,
              selectedColor != nil,
              selectedEmoji != nil,
              !selectedDays.isEmpty,
              selectedCategory != nil else {
            return false
        }
        return true
    }
    
    private func updateCreateButtonState() {
        let isValid = checkFields()
        createButton.isEnabled = isValid
        
        if isValid {
            if traitCollection.userInterfaceStyle == .dark {
                createButton.backgroundColor = .white
                createButton.setTitleColor(.black, for: .normal)
            } else {
                createButton.backgroundColor = .black
                createButton.setTitleColor(.white, for: .normal)
            }
        } else {
            createButton.backgroundColor = .lightGray
            createButton.setTitleColor(.white, for: .normal)
        }
    }
    
    private func saveTracker() {
        guard let name = trackNaming.text, !name.isEmpty,
              let color = selectedColor,
              let emoji = selectedEmoji,
              !selectedDays.isEmpty,
              let category = selectedCategory else {
            return
        }
        
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: Array(selectedDays)
        )
        
        trackerCategoryStore.saveTracker(newTracker, forCategoryTitle: category.titles)
        trackerDelegate?.didFinishCreatingTracker(trackerType: trackerType ?? .habit)
    }
    
    private func updateTracker(_ tracker: Tracker) {
        guard let name = trackNaming.text, !name.isEmpty,
              let color = selectedColor,
              let emoji = selectedEmoji,
              !selectedDays.isEmpty,
              let category = selectedCategory else {
            return
        }
        
        if let oldCategory = trackerCategoryStore.categories.first(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) {
            // Удаляем трекер из старой категории
            trackerCategoryStore.removeTrackerFromCategory(tracker, fromCategoryTitle: oldCategory.titles)
        }
        
        let updatedTracker = Tracker(
            id: tracker.id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: Array(selectedDays)
        )

        trackerCategoryStore.saveTracker(updatedTracker, forCategoryTitle: category.titles)
        trackerDelegate?.didFinishCreatingTracker(trackerType: trackerType ?? .habit)
    }
    
    
    func configureForEditing(_ tracker: Tracker) {
        self.trackerBeingEdited = tracker
        self.trackNaming.text = tracker.name
        self.selectedColor = tracker.color
        self.selectedEmoji = tracker.emoji
        self.selectedDays = Set(tracker.schedule)
        self.selectedCategory = trackerCategoryStore.categories.first(where: { $0.trackers.contains(where: { $0.id == tracker.id }) })
        isEditingTracker = true
        trackerBeingEdited = tracker
        updateCategoryLabel()
        updateCreateButtonState()
    }
    
    @objc
    private func cancelButtonTapped() {
        if isEditingTracker {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    private func createButtonTapped() {
        if isEditingTracker, let trackerBeingEdited = trackerBeingEdited {
            updateTracker(trackerBeingEdited)
        } else {
            saveTracker()
        }
        navigationController?.popToRootViewController(animated: true)
    }
}

extension HabitViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.categoryAndScheduleCollectionView {
            return arrayCells.count
        } else if collectionView == emojiCollectionView {
            return emojiArray.count
        } else if collectionView == colorCollectionView {
            return colorArray.count
        }
        return 0
    }
    
    private func cellCategoryAndSchedual(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CellType1
        
        if indexPath.row == 1 {
            let daysText = selectedDays.map { $0.localizedShortName }.joined(separator: ", ")
            cell.configure(title: arrayCells[indexPath.row], days: daysText.isEmpty ? nil : daysText)
        } else {
            cell.configure(title: arrayCells[indexPath.item], days: selectedCategory?.titles)
        }
        return cell
    }
    
    private func cellEmoji(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        cell.emojiLabel.text = emojiArray[indexPath.item]
        cell.setSelected(indexPath == selectedEmojiIndex)
        return cell
    }
    
    private func cellColor(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        cell.configure(with: colorArray[indexPath.item])
        cell.setSelected(indexPath == selectedColorIndex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.categoryAndScheduleCollectionView {
            return cellCategoryAndSchedual(collectionView, indexPath)
        } else if collectionView == emojiCollectionView {
            return cellEmoji(collectionView, indexPath)
        } else if collectionView == colorCollectionView {
            return cellColor(collectionView, indexPath)
        }
        return UICollectionViewCell()
    }
}

extension HabitViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == emojiCollectionView {
            let padding: CGFloat = 20
            let itemsPerRow: CGFloat = 6
            let itemWidth = (collectionView.frame.width - padding * (itemsPerRow - 1)) / itemsPerRow
            return CGSize(width: itemWidth, height: itemWidth)
            
        } else if collectionView == colorCollectionView {
            let padding: CGFloat = 15
            let itemsPerRow: CGFloat = 6
            let itemWidth = (collectionView.frame.width - padding * (itemsPerRow - 1)) / itemsPerRow
            return CGSize(width: itemWidth, height: itemWidth)
        }
        return CGSize(width: collectionView.frame.width, height: 75 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == colorCollectionView {
            return 10
        } else {
            return 0
        }
    }
}

extension HabitViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryAndScheduleCollectionView {
            collectionView.deselectItem(at: indexPath, animated: true)
            switch indexPath.row {
            case 0:
                guard let categoryVC = categoryViewController else { return }
                navigationController?.pushViewController(categoryVC, animated: true)
            case 1:
                let scheduleViewController = ScheduleViewController(delegate: self, selectedDays: selectedDays)
                let nav = UINavigationController(rootViewController: scheduleViewController)
                present(nav, animated: true)
            default:
                break
            }
        } else if collectionView == emojiCollectionView {
            if selectedEmojiIndex == indexPath {
                selectedEmojiIndex = nil
                selectedEmoji = nil
            } else {
                selectedEmojiIndex = indexPath
                selectedEmoji = emojiArray[indexPath.item]
            }
            collectionView.reloadData()
            updateCreateButtonState()
            
        } else if collectionView == colorCollectionView {
            if selectedColorIndex == indexPath {
                selectedColorIndex = nil
                selectedColor = nil
            } else {
                selectedColorIndex = indexPath
                selectedColor = colorArray[indexPath.item]
            }
            collectionView.reloadData()
            updateCreateButtonState()
        }
    }
}

extension HabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()// Скрыть клавиатуру
        updateCreateButtonState()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == trackNaming {
            if let text = textField.text,
               let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                if updatedText.count >= 38 {
                    showCharacterLimitLabel()
                } else {
                    hideCharacterLimitLabel()
                }
                updateCreateButtonState()
                return updatedText.count <= 38
            }
        }
        return true
    }
    
    private func showCharacterLimitLabel() {
        characterLimitLabel.isHidden = false
    }
    
    private func hideCharacterLimitLabel() {
        characterLimitLabel.isHidden = true
    }
}

extension HabitViewController: TimetableDelegate {
    
    func didUpdateSelectedDays(_ selectedDays: Set<Days>) {
        self.selectedDays = selectedDays
        print("Selected days updated in HabitViewController: \(selectedDays)")
        DispatchQueue.main.async {
            self.categoryAndScheduleCollectionView.reloadData()
            self.updateCreateButtonState()
        }
    }
}

