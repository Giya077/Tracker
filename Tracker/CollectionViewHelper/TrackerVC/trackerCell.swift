//
//  trackerCell.swift
//  Tracker
//
//  Created by GiyaDev on 08.06.2024.
//

import Foundation

import UIKit

class TrackerCell: UICollectionViewCell {
    
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.numberOfLines = 0
        return nameLabel
    }()
    
    let emojiPlaceholder: UIView = {
        let placeholder = UIView()
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        placeholder.layer.cornerRadius = 18
        placeholder.layer.masksToBounds = true
        return placeholder
    }()
    
    let daysLabel: UILabel = {
        let daysLabel = UILabel()
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.textColor = .black
        daysLabel.font = UIFont.systemFont(ofSize: 16)
        return daysLabel
    }()
    
    let contrainerViewCell: UIView = {
        let contrainerView = UIView()
        contrainerView.layer.cornerRadius = 16
        contrainerView.layer.masksToBounds = true
        contrainerView.layer.borderWidth = 2
        contrainerView.translatesAutoresizingMaskIntoConstraints = false
        return contrainerView
    }()
    
    let buttonContainer: UIView = {
        let placeholder = UIView()
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.layer.cornerRadius = 20
        placeholder.layer.masksToBounds = true
        return placeholder
    }()
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        let imageSize: CGFloat = 20
//        button.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
//        button.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        return button
        
    }()
    
    private var tracker: Tracker?
    var isCompleted: Bool = false {
        didSet {
            updateButtonAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        addSubview(contrainerViewCell)
        addSubview(nameLabel)
        addSubview(daysLabel)
        addSubview(buttonContainer)
        addSubview(emojiPlaceholder)
        
        emojiPlaceholder.addSubview(emojiLabel)
        buttonContainer.addSubview(actionButton)
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            contrainerViewCell.topAnchor.constraint(equalTo: topAnchor),
            contrainerViewCell.leadingAnchor.constraint(equalTo: leadingAnchor),
            contrainerViewCell.trailingAnchor.constraint(equalTo: trailingAnchor),
            contrainerViewCell.heightAnchor.constraint(equalToConstant: 100),
            
            emojiPlaceholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            emojiPlaceholder.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            emojiPlaceholder.widthAnchor.constraint(equalToConstant: 36),
            emojiPlaceholder.heightAnchor.constraint(equalToConstant: 36),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiPlaceholder.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiPlaceholder.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: emojiPlaceholder.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: emojiPlaceholder.topAnchor, constant: 40),
            nameLabel.trailingAnchor.constraint(equalTo: contrainerViewCell.trailingAnchor, constant: 10),
            nameLabel.bottomAnchor.constraint(equalTo: contrainerViewCell.bottomAnchor, constant: -5),
            
            daysLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            daysLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            buttonContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            buttonContainer.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor),
            buttonContainer.widthAnchor.constraint(equalToConstant: 40),
            buttonContainer.heightAnchor.constraint(equalToConstant: 40),
            
            actionButton.centerXAnchor.constraint(equalTo: buttonContainer.centerXAnchor),
            actionButton.centerYAnchor.constraint(equalTo: buttonContainer.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 40),
            actionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        updateButtonAppearance()
    }
    
    private func updateButtonAppearance() {
        let buttonImage = isCompleted ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        actionButton.setImage(buttonImage, for: .normal)
        actionButton.tintColor = isCompleted ? UIColor.white.withAlphaComponent(0.2) : UIColor.white
    }
    
    private func formatDaysString(_ count: Int) -> String {
        switch count {
        case 1:
            return "\(count) день"
        case 2...4:
            return "\(count) дня"
        default:
            return "\(count) дней"
        }
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, completionCount: Int) {
        self.tracker = tracker
        nameLabel.text = tracker.name
        daysLabel.text = formatDaysString(completionCount)
        emojiLabel.text = String(tracker.emoji)
        contrainerViewCell.backgroundColor = tracker.color
        contrainerViewCell.layer.borderColor = tracker.color.withAlphaComponent(0.9).cgColor
        buttonContainer.backgroundColor = tracker.color
        self.isCompleted = isCompleted
        updateButtonAppearance()
    }
    
    @objc private func actionButtonTapped() {
        guard let tracker = tracker else { return }
        isCompleted.toggle()
        NotificationCenter.default.post(name: .trackerCompletionChanged, object: nil, userInfo: ["trackerId": tracker.id, "isCompleted": isCompleted])
        updateButtonAppearance()
    }
    
}

class HeaderViewTrackerCollection: UICollectionReusableView {
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .black
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NSNotification.Name {
    static let trackerCompletionChanged = NSNotification.Name("trackerCompletionChanged")
}
