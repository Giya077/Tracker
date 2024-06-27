//
//  HabitViewController.swift
//  Tracker
//
//  Created by GiyaDev on 14.05.2024.
//

import UIKit

class HabitViewController: UIViewController {
    
    weak var trackerDelegate: NewTrackerDelegate?
    
    var categoryViewController: CategoryViewController?
    var trackerCategoryStore: TrackerCategoryStore
    
    var trackerType: TrackerType?
    var selectedDays: Set<Days> = []
    var selectedCategory: TrackerCategory?
    var selectedColor: UIColor?
    var selectedEmoji: String?
    
    var selectedEmojiIndex: IndexPath?
    var selectedColorIndex: IndexPath?
    
    let label: UILabel = {
        let label = BasicTextLabel(text: "Новая привычка")
        return label
    }()
    
    let trackNaming: UITextField = {
        let trackNaming = UITextField()
        trackNaming.textColor = .black
        trackNaming.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        trackNaming.layer.cornerRadius = 10
        trackNaming.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: trackNaming.frame.height))
        trackNaming.leftViewMode = .always
        trackNaming.font = UIFont.systemFont(ofSize: 18)
        trackNaming.attributedPlaceholder = NSAttributedString(string: "Введите название трекера", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        trackNaming.translatesAutoresizingMaskIntoConstraints = false
        return trackNaming
    }()
    
    private let characterLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let arrayCells = ["Категория", "Расписание"]
    let cellIdentifier = "CellType1"
    lazy var categoryAndScheduleCollectionView: UICollectionView = {
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
    
    let contrainerView: UIView = {
        let contrainerView = UIView()
        contrainerView.backgroundColor = Colors.systemSearchColor
        contrainerView.layer.cornerRadius = 10
        contrainerView.layer.masksToBounds = true
        contrainerView.translatesAutoresizingMaskIntoConstraints = false
        return contrainerView
    }()
    
    let separatorLine: UIView = {
        let separatorLine = UIView()
        separatorLine.backgroundColor = .lightGray
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        return separatorLine
    }()
    
    let emojiHeaderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Emoji"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let colorsHeaderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Цвет"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    var emojiArray = ["😊", "🚀", "🎉", "⭐️", "🌈", "🎈", "🍀", "🌺", "🐶", "🐱", "🐰", "🐻", "🦄", "🍔", "🍕", "🍰", "🎸", "📚"]
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
    
    var colorArray: [UIColor] = [.sLightPurple, .sfBlue, .sfCaesarPurple, .sfChampagne, .sfDarkPurple, .sfFial, .sfGreen, .sfGreenLawn, .sfLightPink, .sfOceanBlue, .sfOrange, .sfPamelaOrange, .sfPink, .sfPinkyPink, .sfPurple, .sfRed, .sfSystemPurple, .sfTiffany]
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
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.backgroundColor = .white
        cancelButton.layer.cornerRadius = 12
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.layer.masksToBounds = true
        cancelButton.tintColor = .red
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 19)
        cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return cancelButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = UIButton(type: .system)
        createButton.setTitle("Создать", for: .normal)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        createButton.layer.cornerRadius = 12
        createButton.layer.masksToBounds = true
        createButton.tintColor = .white
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 19)
        createButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return createButton
    }()
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        
        categoryViewController = CategoryViewController(trackerCategoryStore: trackerCategoryStore)
        categoryViewController?.categorySelectionDelegate = self
        
        stackViewButton()
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
    
    private func setupView() {
        
        view.addSubview(label)
        view.addSubview(trackNaming)
        view.addSubview(contrainerView)
        view.addSubview(separatorLine)
        view.addSubview(categoryAndScheduleCollectionView)
        view.addSubview(emojiHeaderLabel)
        view.addSubview(emojiCollectionView)
        view.addSubview(colorsHeaderLabel)
        view.addSubview(colorCollectionView)
        view.addSubview(characterLimitLabel)
        
        hideCharacterLimitLabel()
        
        NSLayoutConstraint.activate([
            
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackNaming.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
            trackNaming.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            trackNaming.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            trackNaming.heightAnchor.constraint(equalToConstant: 50),
            
            characterLimitLabel.topAnchor.constraint(equalTo: trackNaming.bottomAnchor, constant: 5),
            characterLimitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
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
        ])
        
        //EmojiCollectionvView
                
        NSLayoutConstraint.activate([
            
            emojiHeaderLabel.topAnchor.constraint(equalTo: contrainerView.bottomAnchor, constant: 15),
            emojiHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiHeaderLabel.bottomAnchor, constant: 10),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 130),
            
            colorsHeaderLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 10),
            colorsHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),

            colorCollectionView.topAnchor.constraint(equalTo: colorsHeaderLabel.bottomAnchor, constant: 15),
            colorCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            colorCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }
    
    private func stackViewButton() {
        let stackViewButton = UIStackView(arrangedSubviews: [cancelButton,createButton])
        stackViewButton.axis = .horizontal
        stackViewButton.spacing = 15
        stackViewButton.distribution = .fillEqually
        stackViewButton.alignment = .fill
        view.addSubview(stackViewButton)
        stackViewButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackViewButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor),
            stackViewButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackViewButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackViewButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updateCategoryLabel() {
        guard let categoryCell = categoryAndScheduleCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? CellType1 else { return }
        // Создаем строку, содержащую названия всех выбранных категорий, разделенные запятыми
        let categoriesText = selectedCategory?.titles ?? ""
        // Обновляем текст в ячейке с категорией
        categoryCell.configure(title: "Категория", days: categoriesText.isEmpty ? nil : categoriesText)
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
        createButton.isEnabled = checkFields()
        createButton.backgroundColor = createButton.isEnabled ? .black : .lightGray
    }
    
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func createButtonTapped() {
        guard let name = trackNaming.text,
              let selectedColor = selectedColor,
              let selectedEmoji = selectedEmoji,
              let category = selectedCategory else {
            return
        }
        let schedule = Array(selectedDays)
        let newTracker = Tracker(id: UUID(), name: name, color: selectedColor, emoji: selectedEmoji, schedule: schedule)
        
        guard let trackerType = trackerType else { return }
        
        let trackerCategory = TrackerCategory(titles: category.titles, trackers: [newTracker]) // ?? TrackerStore!!
        
        trackerDelegate?.didAddTracker(newTracker, to: trackerCategory, trackerType: trackerType) // to newTracker
        self.dismiss(animated: true)
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
        
        // Проверяем, является ли текущая ячейка Расписанием
        if indexPath.row == 1 {
            let daysText = selectedDays.map { $0.rawValue }.joined(separator: ", ")
            cell.configure(title: arrayCells[indexPath.row], days: daysText.isEmpty ? nil : daysText)
        } else {
            // Если это не ячейка Расписание, передаем nil для daysLabel
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
         // Проверяем, что это наше текстовое поле
         if textField == trackNaming {
             // Проверяем, что текст после изменений не превышает 38 символов
             if let text = textField.text,
                let textRange = Range(range, in: text) {
                 let updatedText = text.replacingCharacters(in: textRange, with: string)
                 // Проверяем, достигнуто ли ограничение
                 if updatedText.count >= 38 {
                     // Отображаем метку
                     showCharacterLimitLabel()
                 } else {
                     // Скрываем метку, если текст в пределах ограничения
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

extension HabitViewController: NewCategoryViewControllerDelegate {
    func removeStubAndShowCategories() {
    }
    
    func didAddCategory(_ category: TrackerCategory) {
        selectedCategory = category
        updateCategoryLabel()
        updateCreateButtonState()
    }
}

extension HabitViewController: CategorySelectionDelegate { // делегат для передачи выбранной категории от CategoryViewController к HabitViewController.
    
    func didSelectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        updateCategoryLabel()
        updateCreateButtonState()
    }
}



