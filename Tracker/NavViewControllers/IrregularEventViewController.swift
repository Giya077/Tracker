//
//  irregularEventViewController.swift
//  Tracker
//
//  Created by GiyaDev on 14.05.2024.
//

import Foundation
import UIKit

final class IrregularEventViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var trackerDelegate: NewTrackerDelegate?
    var trackerType: TrackerType?
    
    // MARK: - Private Properties
    private var selectedCategory: TrackerCategory?
    private var trackerCategoryStore: TrackerCategoryStore
    private var categoryViewController: CategoryViewController?
    
    private var selectedColor: UIColor?
    private var selectedEmoji: String?
    private var selectedEmojiIndex: IndexPath?
    private var selectedColorIndex: IndexPath?
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    
    private let label: UILabel = {
        let label = BasicTextLabel(text: "Новое нерегулярное событие")
        return label
    }()
    
    private let trackNaming: UITextField = {
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
    
    private let arrayCells = ["Категория"]
    private let cellIdentifier = "CellType1"
    private lazy var categoryCollectionView: UICollectionView = {
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
    
    private let emojiHeaderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Emoji"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let colorsHeaderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Цвет"
        label.font = UIFont.boldSystemFont(ofSize: 18)
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
    
    // MARK: - Initializers
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
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        
        setupScrollView()
        setupView()
        
        categoryViewController = CategoryViewController(trackerCategoryStore: trackerCategoryStore)
        categoryViewController?.categorySelectionDelegate = self
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        trackNaming.delegate = self
        
        createButton.isEnabled = false
        createButton.backgroundColor = .lightGray
        
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
        contentView.addSubview(categoryCollectionView)
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
            trackNaming.heightAnchor.constraint(equalToConstant: 50),
            
            characterLimitLabel.topAnchor.constraint(equalTo: trackNaming.bottomAnchor, constant: 5),
            characterLimitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            categoryCollectionView.topAnchor.constraint(equalTo: characterLimitLabel.bottomAnchor, constant: 10),
            categoryCollectionView.leadingAnchor.constraint(equalTo: trackNaming.leadingAnchor),
            categoryCollectionView.trailingAnchor.constraint(equalTo: trackNaming.trailingAnchor),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 150),
            
            contrainerView.topAnchor.constraint(equalTo: categoryCollectionView.topAnchor),
            contrainerView.leadingAnchor.constraint(equalTo: categoryCollectionView.leadingAnchor),
            contrainerView.trailingAnchor.constraint(equalTo: categoryCollectionView.trailingAnchor),
            contrainerView.heightAnchor.constraint(equalToConstant: 75),
        
        //EmojiCollectionvView
                    
            emojiHeaderLabel.topAnchor.constraint(equalTo: contrainerView.bottomAnchor, constant: 25),
            emojiHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiHeaderLabel.bottomAnchor, constant: 15),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 130),
            
            //ColorCollectionvView
            
            colorsHeaderLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 15),
            colorsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorsHeaderLabel.bottomAnchor, constant: 25),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
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
        guard let categoryCell = categoryCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? CellType1 else { return }
        let categoriesText = selectedCategory?.titles ?? ""
        // Обновляем текст в ячейке с категорией
        categoryCell.configure(title: "Категория", days: categoriesText.isEmpty ? nil : categoriesText)
    }
    
    private func checkFields() -> Bool {
        guard let name = trackNaming.text, !name.isEmpty,
              selectedColor != nil,
              selectedEmoji != nil,
              selectedCategory != nil else {
            return false
        }
        return true
    }
    
    private func updateCreateButtonState() {
        createButton.isEnabled = checkFields()
        createButton.backgroundColor = createButton.isEnabled ? .black : .lightGray
    }
    
    private func saveEvent() {
        guard let name = trackNaming.text, !name.isEmpty,
              let color = selectedColor,
              let emoji = selectedEmoji,
              let category = selectedCategory else {
            return // Handle the error or show an alert
        }
        
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
            schedule: [] // Empty schedule for irregular events
        )
        
        trackerCategoryStore.saveTracker(newTracker, forCategoryTitle: category.titles)
        trackerDelegate?.didFinishCreatingTracker(trackerType: .event)
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func createButtonTapped() {
        saveEvent()
        navigationController?.popToRootViewController(animated: true)
    }
}


extension IrregularEventViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.categoryCollectionView {
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
        
            cell.configure(title: arrayCells[indexPath.item], days: selectedCategory?.titles)
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
        if collectionView == self.categoryCollectionView {
            return cellCategoryAndSchedual(collectionView, indexPath)
        } else if collectionView == emojiCollectionView {
            return cellEmoji(collectionView, indexPath)
        } else if collectionView == colorCollectionView {
            return cellColor(collectionView, indexPath)
        }
        return UICollectionViewCell()
    }
}
	
extension IrregularEventViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            collectionView.deselectItem(at: indexPath, animated: true)
            switch indexPath.row {
            case 0:
                guard let categoryVC = categoryViewController else { return }
                navigationController?.pushViewController(categoryVC, animated: true)
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

extension IrregularEventViewController: UICollectionViewDelegateFlowLayout {
    
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

extension IrregularEventViewController: UITextFieldDelegate {
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

extension IrregularEventViewController: NewCategoryViewControllerDelegate {
    func removeStubAndShowCategories() {
    }
    
    func didAddCategory(_ category: TrackerCategory) {
        selectedCategory = category
        updateCategoryLabel()
        updateCreateButtonState()
    }
}

extension IrregularEventViewController: CategorySelectionDelegate { // делегат для передачи выбранной категории от CategoryViewController к HabitViewController.
    
    func didSelectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        updateCategoryLabel()
        updateCreateButtonState()
    }
}
