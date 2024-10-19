//
//  trackerCell.swift
//  Tracker
//
//  Created by GiyaDev on 08.06.2024.
//

import Foundation

import UIKit

class TrackerCell: UICollectionViewCell {
    
    var isCompleted: Bool = false {
        didSet {
            updateButtonAppearance()
        }
    }
    
    var isPinned: Bool = false {
        didSet {
            pinIconImageView.isHidden = !isPinned
        }
    }
    
    private var currentDate: Date = Date()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private  let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        nameLabel.numberOfLines = 0
        return nameLabel
    }()
    
    private let emojiPlaceholder: UIView = {
        let placeholder = UIView()
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        placeholder.layer.cornerRadius = 18
        placeholder.layer.masksToBounds = true
        return placeholder
    }()
    
    private let pinIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "pin"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.isHidden = true
        return imageView
    }()
    
    private let daysLabel: UILabel = {
        let daysLabel = UILabel()
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.textColor = UIColor.label
        daysLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return daysLabel
    }()
    
    private let contrainerViewCell: UIView = {
        let contrainerView = UIView()
        contrainerView.layer.cornerRadius = 16
        contrainerView.layer.masksToBounds = true
        contrainerView.layer.borderWidth = 1
        contrainerView.translatesAutoresizingMaskIntoConstraints = false
        return contrainerView
    }()
    
    private let buttonContainer: UIView = {
        let placeholder = UIView()
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.layer.borderWidth = 1
        placeholder.layer.cornerRadius = 17
        placeholder.layer.masksToBounds = true
        placeholder.heightAnchor.constraint(equalToConstant: 34).isActive = true
        placeholder.widthAnchor.constraint(equalToConstant: 34).isActive = true
        return placeholder
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private lazy var tapAreaButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var tracker: Tracker?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, completionCount: Int, currentDate: Date, isPinned: Bool) {
        self.tracker = tracker
        self.currentDate = currentDate
        self.isPinned = isPinned
        nameLabel.text = tracker.name
        daysLabel.text = formatDaysString(completionCount)
        emojiLabel.text = String(tracker.emoji)
        contrainerViewCell.backgroundColor = tracker.color
        contrainerViewCell.layer.borderColor = tracker.color.withAlphaComponent(0.9).cgColor
        buttonContainer.backgroundColor = tracker.color
        buttonContainer.layer.borderColor = tracker.color.withAlphaComponent(0.9).cgColor
        self.isCompleted = isCompleted
        updateButtonAppearance()
    }
    
    private func setupViews() {
        
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        addSubview(contrainerViewCell)
        addSubview(pinIconImageView)
        addSubview(nameLabel)
        addSubview(daysLabel)
        addSubview(buttonContainer)
        addSubview(emojiPlaceholder)
        addSubview(tapAreaButton)
        
        emojiPlaceholder.addSubview(emojiLabel)
        buttonContainer.addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            
            contrainerViewCell.topAnchor.constraint(equalTo: topAnchor),
            contrainerViewCell.leadingAnchor.constraint(equalTo: leadingAnchor),
            contrainerViewCell.trailingAnchor.constraint(equalTo: trailingAnchor),
            contrainerViewCell.heightAnchor.constraint(equalToConstant: 90),
            
            emojiPlaceholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            emojiPlaceholder.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            emojiPlaceholder.widthAnchor.constraint(equalToConstant: 36),
            emojiPlaceholder.heightAnchor.constraint(equalToConstant: 36),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiPlaceholder.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiPlaceholder.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: emojiPlaceholder.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: emojiPlaceholder.topAnchor, constant: 40),
            nameLabel.trailingAnchor.constraint(equalTo: contrainerViewCell.trailingAnchor, constant: -10),
            nameLabel.bottomAnchor.constraint(equalTo: contrainerViewCell.bottomAnchor, constant: -5),
            
            pinIconImageView.topAnchor.constraint(equalTo: contrainerViewCell.topAnchor, constant: 10),
            pinIconImageView.trailingAnchor.constraint(equalTo: contrainerViewCell.trailingAnchor, constant: -10),
            pinIconImageView.widthAnchor.constraint(equalToConstant: 8),
            pinIconImageView.heightAnchor.constraint(equalToConstant: 12),
            
            daysLabel.topAnchor.constraint(equalTo: contrainerViewCell.bottomAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            
            buttonContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            buttonContainer.topAnchor.constraint(equalTo: contrainerViewCell.bottomAnchor, constant: 8),
            
            actionButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            actionButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 10.63),
            actionButton.heightAnchor.constraint(equalToConstant: 10.21),
            
            tapAreaButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            tapAreaButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            tapAreaButton.widthAnchor.constraint(equalToConstant: 44),
            tapAreaButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        updateButtonAppearance()
    }
    
    private func updateButtonAppearance() {
        let buttonImage = isCompleted ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        actionButton.setImage(buttonImage, for: .normal)
        actionButton.tintColor = isCompleted ? UIColor.white.withAlphaComponent(0.5) : UIColor.white
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        actionButton.setPreferredSymbolConfiguration(configuration, forImageIn: .normal)
        
        self.alpha = self.isCompleted ? 0.5 : 1.0
    }
    
    private func formatDaysString(_ count: Int) -> String {
        return String.localizedStringWithFormat(
            NSLocalizedString("daysCount", comment: "Количество дней"), count
        )
    }
    
    @objc private func actionButtonTapped() {
        
        AnalyticsService.shared.logEvent("click", parameters: [
            "screen": "Main",
            "item": "track"
        ])
        print("Отправлено событие: click, screen: Main, item: track")
        
        guard let tracker = tracker else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDay = Calendar.current.startOfDay(for: currentDate)
        
        if selectedDay > today {
            print("Нельзя отмечать трекеры для будущих дат.")
            return
        }
        
        isCompleted.toggle()
        NotificationCenter.default.post(name: .trackerCompletionChanged, object: nil, userInfo: ["trackerId": tracker.id, "isCompleted": isCompleted])
        updateButtonAppearance()
    }
    
    override var isSelected: Bool {
        didSet {
            contrainerViewCell.layer.borderColor = isSelected ? UIColor.blue.cgColor : tracker?.color.withAlphaComponent(0.9).cgColor
        }
    }
}

class HeaderViewTrackerCollection: UICollectionReusableView {
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor.label
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
}

extension NSNotification.Name {
    static let trackerCompletionChanged = NSNotification.Name("trackerCompletionChanged")
}
