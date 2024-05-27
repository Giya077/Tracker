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
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CellType1.self, forCellWithReuseIdentifier: "CellType1")
        return collectionView
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
    lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
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
    
    lazy var createButton: UIButton = {
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
    
    let categoryLabel: UILabel = {
        let categoryLabel = UILabel()
        categoryLabel.textColor = .gray
        categoryLabel.font = UIFont.systemFont(ofSize: 16)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        return categoryLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        stackViewButton()
        trackNaming.delegate = self
    }
    
    private func setupView() {
        categoryAndScheduleCollectionView.delegate = self
        categoryAndScheduleCollectionView.dataSource = self
        
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        
        view.addSubview(categoryLabel)
        view.addSubview(label)
        view.addSubview(trackNaming)
        view.addSubview(categoryAndScheduleCollectionView)
        view.addSubview(emojiTextLabel)
        view.addSubview(emojiCollectionView)
        
        NSLayoutConstraint.activate([
            
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackNaming.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 50),
            trackNaming.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            trackNaming.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            trackNaming.heightAnchor.constraint(equalToConstant: 100),
            
            categoryAndScheduleCollectionView.topAnchor.constraint(equalTo: trackNaming.bottomAnchor, constant: 20),
            categoryAndScheduleCollectionView.leadingAnchor.constraint(equalTo: trackNaming.leadingAnchor),
            categoryAndScheduleCollectionView.trailingAnchor.constraint(equalTo: trackNaming.trailingAnchor),
            categoryAndScheduleCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            emojiTextLabel.topAnchor.constraint(equalTo: categoryAndScheduleCollectionView.bottomAnchor, constant: 20),
            emojiTextLabel.leadingAnchor.constraint(equalTo: categoryAndScheduleCollectionView.leadingAnchor),
            
            categoryLabel.topAnchor.constraint(equalTo: categoryAndScheduleCollectionView.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            categoryLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
        //emojiCollectionView
        
        let cellWidth: CGFloat = 50
        let cellHeight: CGFloat = 50
        let padding: CGFloat = 10
        let cellsPerRow = 6
        
        let collectionWidth = cellWidth * CGFloat(cellsPerRow) + padding /** CGFloat(cellsPerRow - 1)*/
        let collectionViewHeight = cellHeight * 3 + padding * 2 // 3 строки эмодзи с отступами
        
        NSLayoutConstraint.activate([
            emojiCollectionView.widthAnchor.constraint(equalToConstant: collectionWidth),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight),
            emojiCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emojiCollectionView.topAnchor.constraint(equalTo: emojiTextLabel.bottomAnchor, constant: padding)
        ])
        
        if let layout = emojiCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
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
            stackViewButton.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 20),
            stackViewButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackViewButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
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
              let category = selectedCategory else {
            return
        }
        let schedule = Array(selectedDays)
        let newTracker = Tracker(id: UUID(), name: name, schedule: schedule, categoryTitle: category.titles)
        // Вызываем делегата для создания нового трекера
        trackerDelegate?.didAddTracker(newTracker)
        self.dismiss(animated: true)
    }
}


extension HabitViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.categoryAndScheduleCollectionView {
            return arrayCells.count
        } else if collectionView == emojiCollectionView {
            return emojiArray.count
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
    
    private func cellEmojiAndColor(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        cell.emojiLabel.text = emojiArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.categoryAndScheduleCollectionView {
            return cellCategoryAndSchedual(collectionView, indexPath)
        } else if collectionView == emojiCollectionView {
            return cellEmojiAndColor(collectionView, indexPath)
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == emojiCollectionView {
            return CGSize(width: 50, height: 50)
        }
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0 // задаем минимальный отступ между строками
    }
    
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
            let selectedEmoji = emojiArray[indexPath.item]
            trackNaming.text = "\(trackNaming.text ?? "")\(selectedEmoji)"
            print("Selected Emoji: \(selectedEmoji)")
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



