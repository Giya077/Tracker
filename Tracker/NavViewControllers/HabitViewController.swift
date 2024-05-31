//
//  HabitViewController.swift
//  Tracker
//
//  Created by GiyaDev on 14.05.2024.
//

import Foundation
import UIKit

class HabitViewController: UIViewController {
    
    weak var delegate: HabitCreationDelegate?
    weak var trackerDelegate: NewTrackerDelegate?
    
    var selectedDays: Set<Days> = []
    var selectedCategory: TrackerCategory?
    var selectedColor: UIColor?
    var selectedEmoji: Character?
    
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
    
    let arrayCells = ["Категория", "Расписание"]
    let cellIdentifier = "CellType1"
    lazy var categoryAndScheduleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
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
    
    lazy var emojiTextLabel: UILabel = {
        let emojiTextLabel = UILabel()
        emojiTextLabel.textColor = .black
        emojiTextLabel.text = "Emoji"
        emojiTextLabel.font = UIFont.boldSystemFont(ofSize: 17)
        emojiTextLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiTextLabel
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
        createButton.backgroundColor = .lightGray
        createButton.layer.cornerRadius = 12
        createButton.layer.masksToBounds = true
        createButton.tintColor = .white
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 19)
        createButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return createButton
    }()
    
    private let categoryLabel: UILabel = {
        let categoryLabel = UILabel()
        categoryLabel.textColor = .gray
        categoryLabel.font = UIFont.systemFont(ofSize: 16)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        return categoryLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        stackViewButton()
        setupView()
        trackNaming.delegate = self
    }
    
    private func setupView() {
        categoryAndScheduleCollectionView.delegate = self
        categoryAndScheduleCollectionView.dataSource = self
        
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        
        view.addSubview(categoryLabel)
        view.addSubview(label)
        view.addSubview(trackNaming)
        view.addSubview(contrainerView)
        view.addSubview(separatorLine)
        view.addSubview(categoryAndScheduleCollectionView)
        view.addSubview(emojiTextLabel)
        view.addSubview(emojiCollectionView)
        view.addSubview(colorCollectionView)
        
        NSLayoutConstraint.activate([
            
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackNaming.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
            trackNaming.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            trackNaming.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            trackNaming.heightAnchor.constraint(equalToConstant: 50),
            
            categoryAndScheduleCollectionView.topAnchor.constraint(equalTo: trackNaming.bottomAnchor, constant: 20),
            categoryAndScheduleCollectionView.leadingAnchor.constraint(equalTo: trackNaming.leadingAnchor),
            categoryAndScheduleCollectionView.trailingAnchor.constraint(equalTo: trackNaming.trailingAnchor),
            categoryAndScheduleCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            contrainerView.topAnchor.constraint(equalTo: categoryAndScheduleCollectionView.topAnchor),
            contrainerView.leadingAnchor.constraint(equalTo: categoryAndScheduleCollectionView.leadingAnchor),
            contrainerView.trailingAnchor.constraint(equalTo: categoryAndScheduleCollectionView.trailingAnchor),
            contrainerView.heightAnchor.constraint(equalToConstant: 200),
            
            separatorLine.leadingAnchor.constraint(equalTo: contrainerView.leadingAnchor, constant: 20),
            separatorLine.trailingAnchor.constraint(equalTo: contrainerView.trailingAnchor, constant: -20),
            separatorLine.centerYAnchor.constraint(equalTo: contrainerView.centerYAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            emojiTextLabel.topAnchor.constraint(equalTo: categoryAndScheduleCollectionView.bottomAnchor, constant: 20),
            emojiTextLabel.leadingAnchor.constraint(equalTo: categoryAndScheduleCollectionView.leadingAnchor),
            
            categoryLabel.topAnchor.constraint(equalTo: categoryAndScheduleCollectionView.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            categoryLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        //EmojiCollectionvView
                
        NSLayoutConstraint.activate([
            emojiCollectionView.topAnchor.constraint(equalTo: emojiTextLabel.bottomAnchor, constant: 10),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // ColorCollectionView
        
        NSLayoutConstraint.activate([
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 10),
            colorCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            colorCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            colorCollectionView.bottomAnchor.constraint(equalTo: createButton.topAnchor)
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
            stackViewButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackViewButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackViewButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updateCategoryLabel() {
        guard let categoryCell = categoryAndScheduleCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? CellType1 else { return }
        categoryCell.configure(title: "Категория", days: selectedCategory?.titles)
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
        let newTracker = Tracker(id: UUID(), name: name, color: selectedColor, emoji: selectedEmoji, schedule: schedule, categoryTitle: category.titles)
        // Вызываем делегата для создания нового трекера
        
        trackerDelegate?.didAddTracker(newTracker)
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
            let padding: CGFloat = 10
            let itemsPerRow: CGFloat = 6
            let itemWidth = (collectionView.frame.width - padding * (itemsPerRow - 1)) / itemsPerRow
            return CGSize(width: itemWidth, height: itemWidth)
            
        } else if collectionView == colorCollectionView {
            let padding: CGFloat = 10
            let itemsPerRow: CGFloat = 6
            let itemWidth = (collectionView.frame.width - padding * (itemsPerRow - 1)) / itemsPerRow
            return CGSize(width: itemWidth, height: itemWidth)
        }
        return CGSize(width: collectionView.frame.width, height: 100 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension HabitViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryAndScheduleCollectionView {
            collectionView.deselectItem(at: indexPath, animated: true)
            switch indexPath.item {
                
            case 0:
                let categoryViewController = CategoryViewController()
                categoryViewController.categorySelectionDelegate = self
                let nav = UINavigationController(rootViewController: categoryViewController)
                present(nav, animated: true)
                print("categoryViewController tapped")
                
            case 1:
                let scheduleViewController = ScheduleViewController(delegate: self, selectedDays: selectedDays)
                let nav = UINavigationController(rootViewController: scheduleViewController)
                present(nav, animated: true)
                print("scheduleViewController tapped")
                
            default:
                break
            }
        } else if collectionView == emojiCollectionView {
            if selectedEmojiIndex == indexPath {
                selectedEmojiIndex = nil
                selectedEmoji = nil
            } else {
                selectedEmojiIndex = indexPath
                selectedEmoji = emojiArray[indexPath.item].first
            }
            collectionView.reloadData()
            
        } else if collectionView == colorCollectionView {
            if selectedColorIndex == indexPath {
                selectedColorIndex = nil
                selectedColor = nil
            } else {
                selectedColorIndex = indexPath
                selectedColor = colorArray[indexPath.item]
            }
            collectionView.reloadData()
        }
    }
}

extension HabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Скрыть клавиатуру
        return true
    }
}

extension HabitViewController: TimetableDelegate {
    
    func didUpdateSelectedDays(_ selectedDays: Set<Days>) {
        self.selectedDays = selectedDays
        
        // Проверяем, что выбранные дни корректно передаются
        print("Selected days updated in HabitViewController: \(selectedDays)")
        
        // Перезагружаем коллекцию после обновления данных
        DispatchQueue.main.async {
            self.categoryAndScheduleCollectionView.reloadData()
        }
    }
}

extension HabitViewController: NewCategoryViewControllerDelegate {
    func removeStubAndShowCategories() {
    }
    
    func didAddCategory(_ category: TrackerCategory) {
        selectedCategory = category
        categoryLabel.text = category.titles
    }
}

extension HabitViewController: CategorySelectionDelegate { // делегат для передачи выбранной категории от CategoryViewController к HabitViewController.
    func didSelectCategory(_ category: TrackerCategory) {
        self.selectedCategory = category
        updateCategoryLabel()
    }
}



