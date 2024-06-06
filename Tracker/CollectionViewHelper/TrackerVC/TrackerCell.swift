//
//  TrackerCell.swift
//  Tracker
//
//  Created by GiyaDev on 26.05.2024.
//

import UIKit

class TrackerCell: UICollectionViewCell {
    
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
       return label
    }()
    
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 18)
        nameLabel.numberOfLines = 0
        return nameLabel
    }()
    
    let emojiPlaceholder: UIView = {
        let placeholder = UIView()
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        placeholder.layer.cornerRadius = 20
        placeholder.layer.masksToBounds = true
        return placeholder
    }()
    
    let daysLabel: UILabel = {
        let daysLabel = UILabel()
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.textColor = .black
        daysLabel.font = UIFont.systemFont(ofSize: 18)
        return daysLabel
    }()
    
    let contrainerViewCell: UIView = {
        let contrainerView = UIView()
        contrainerView.layer.cornerRadius = 16
        contrainerView.layer.masksToBounds = true
        contrainerView.translatesAutoresizingMaskIntoConstraints = false
        return contrainerView
    }()
    
    let actionButton = UIButton(type: .system)
    
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
        addSubview(actionButton)
        addSubview(emojiPlaceholder)
        addSubview(emojiLabel)
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            contrainerViewCell.topAnchor.constraint(equalTo: topAnchor),
            contrainerViewCell.leadingAnchor.constraint(equalTo: leadingAnchor),
            contrainerViewCell.trailingAnchor.constraint(equalTo: trailingAnchor),
            contrainerViewCell.heightAnchor.constraint(equalToConstant: 100),
            
            emojiPlaceholder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            emojiPlaceholder.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            emojiLabel.leadingAnchor.constraint(equalTo: emojiPlaceholder.leadingAnchor),
            emojiLabel.topAnchor.constraint(equalTo: emojiPlaceholder.topAnchor),
            
//            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: contrainerViewCell.leadingAnchor, constant: 15),
            nameLabel.topAnchor.constraint(equalTo: emojiPlaceholder.topAnchor, constant: 40),
            nameLabel.trailingAnchor.constraint(equalTo: contrainerViewCell.trailingAnchor, constant: 10),
            nameLabel.bottomAnchor.constraint(equalTo: contrainerViewCell.bottomAnchor, constant: -5),
            
            daysLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            daysLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionButton.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 40),
            actionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        updateButtonAppearance()
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, completionCount: Int) {
        self.tracker = tracker
        nameLabel.text = tracker.name
        daysLabel.text = "\(completionCount) дней"
        emojiLabel.text = String(tracker.emoji)
        contrainerViewCell.backgroundColor = tracker.color
        actionButton.tintColor = tracker.color
        self.isCompleted = isCompleted
        backgroundColor = .white
    }
    
    private func updateButtonAppearance() {
        let buttonImage = isCompleted ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "plus.circle.fill")
        actionButton.setImage(buttonImage, for: .normal)
        actionButton.tintColor = isCompleted ? tracker?.color.withAlphaComponent(0.2) : tracker?.color
    }
        
    @objc private func actionButtonTapped() {
        guard let tracker = tracker else { return }
        isCompleted.toggle()
        NotificationCenter.default.post(name: .trackerCompletionChanged, object: nil, userInfo: ["trackerId": tracker.id, "isCompleted": isCompleted])
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
