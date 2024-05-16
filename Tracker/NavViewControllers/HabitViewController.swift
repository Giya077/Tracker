//
//  HabitViewController.swift
//  Tracker
//
//  Created by GiyaDev on 14.05.2024.
//

import Foundation
import UIKit

class HabitViewController: UIViewController {
    
    let newHabitLabel: UILabel = {
        let newHabitLabel = UILabel()
        newHabitLabel.text = "Новая привычка"
        newHabitLabel.textColor = .black
        newHabitLabel.font = UIFont.boldSystemFont(ofSize: 20)
        newHabitLabel.translatesAutoresizingMaskIntoConstraints = false
        return newHabitLabel
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
    
    let array = ["Категория", "Расписание"]
    let cell1Identifier = "CellType1"
    let categoryAndScheduleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CellType1.self, forCellWithReuseIdentifier: "CellType1")
        return collectionView
    }()
    
    let emojiTextLabel: UILabel = {
        let emojiTextLabel = UILabel()
        emojiTextLabel.textColor = .black
        emojiTextLabel.text = "Emoji"
        emojiTextLabel.font = UIFont.boldSystemFont(ofSize: 17)
        emojiTextLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiTextLabel
    }()
    
    var emojiArray = ["😊", "🚀", "🎉", "⭐️", "🌈", "🎈", "🍀", "🌺", "🐶", "🐱", "🐰", "🐻", "🦄", "🍔", "🍕", "🍰", "🎸", "📚"]
    let emojiCollectionView: UICollectionView = {
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
    
   private let cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.backgroundColor = .white
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.red.cgColor
        cancelButton.layer.masksToBounds = true
        cancelButton.tintColor = .red
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return cancelButton
    }()
    
    let createButton: UIButton = {
        let createButton = UIButton(type: .system)
        createButton.setTitle("Создать", for: .normal)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        createButton.backgroundColor = .lightGray
        createButton.layer.cornerRadius = 10
        createButton.layer.masksToBounds = true
        createButton.tintColor = .white
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        createButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return createButton
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
        
        view.addSubview(newHabitLabel)
        view.addSubview(trackNaming)
        view.addSubview(categoryAndScheduleCollectionView)
        view.addSubview(emojiTextLabel)
        view.addSubview(emojiCollectionView)
        
        NSLayoutConstraint.activate([
            
            newHabitLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            newHabitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackNaming.topAnchor.constraint(equalTo: newHabitLabel.bottomAnchor, constant: 50),
            trackNaming.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            trackNaming.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            trackNaming.heightAnchor.constraint(equalToConstant: 100),
            
            categoryAndScheduleCollectionView.topAnchor.constraint(equalTo: trackNaming.bottomAnchor, constant: 20),
            categoryAndScheduleCollectionView.leadingAnchor.constraint(equalTo: trackNaming.leadingAnchor),
            categoryAndScheduleCollectionView.trailingAnchor.constraint(equalTo: trackNaming.trailingAnchor),
            categoryAndScheduleCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            emojiTextLabel.topAnchor.constraint(equalTo: categoryAndScheduleCollectionView.bottomAnchor, constant: 20),
            emojiTextLabel.leadingAnchor.constraint(equalTo: categoryAndScheduleCollectionView.leadingAnchor)
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
//            stackViewButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20)
        ])
    }
    
    @objc
    private func cancelButtonTapped() {
    }
    
    @objc
    private func createButtonTapped() {
    }
}
//        cell.accessoryType = .disclosureIndicator
extension HabitViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.categoryAndScheduleCollectionView {
            return array.count
        } else if collectionView == emojiCollectionView {
            return emojiArray.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.categoryAndScheduleCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell1Identifier, for: indexPath) as! CellType1
            cell.titleLabel.text = array[indexPath.item]
            return cell
        } else if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
            cell.emojiLabel.text = emojiArray[indexPath.item]
            return cell
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
        if collectionView == self.categoryAndScheduleCollectionView {
            collectionView.deselectItem(at: indexPath, animated: true)
            switch indexPath.item {
            case 0:
                let categoryViewController = CategoryViewController()
                let nav = UINavigationController(rootViewController: categoryViewController)
                present(nav, animated: true)
                print("categoryViewController tapped")
                
            case 1:
                let scheduleViewController = ScheduleViewController()
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

//let viewController = NewTrackerViewController()
//viewController.delegate = self
//let nav = UINavigationController(rootViewController: viewController)
//present(nav,animated: true)

extension HabitViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Скрыть клавиатуру
        // В этом месте выполните сохранение введенного текста или обработку по вашему усмотрению
        return true
    }
}


