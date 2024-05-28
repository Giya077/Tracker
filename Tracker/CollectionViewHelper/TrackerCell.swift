//
//  TrackerCell.swift
//  Tracker
//
//  Created by GiyaDev on 26.05.2024.
//

import UIKit

class TrackerCell: UICollectionViewCell {
    let nameLabel = UILabel()
    let daysLabel = UILabel()
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
        setupCellAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = .black
        nameLabel.font = UIFont.systemFont(ofSize: 18)
        nameLabel.numberOfLines = 1
        
        addSubview(daysLabel)
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        daysLabel.textColor = .black
        daysLabel.font = UIFont.systemFont(ofSize: 18)
        
        addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            daysLabel.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            daysLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
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
        self.isCompleted = isCompleted
        backgroundColor = getRandomColor()
    }
    
    private func setupCellAppearance() {
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }
    
    private func updateButtonAppearance() {
        let buttonImage = isCompleted ? UIImage(systemName: "plus.circle.fill") : UIImage(systemName: "checkmark.circle.fill")
        actionButton.setImage(buttonImage, for: .normal)
        actionButton.tintColor = isCompleted ? .green : .green
    }
    
    private func getRandomColor() -> UIColor {
        let colors = [
            UIColor.red, UIColor.green, UIColor.blue,
            UIColor.orange, UIColor.purple, UIColor.yellow
        ]
        return colors.randomElement() ?? .gray
    }
    
    
    @objc private func actionButtonTapped() {
        guard let tracker = tracker else { return }
        isCompleted.toggle()
        NotificationCenter.default.post(name: .trackerCompletionChanged, object: nil, userInfo: ["trackerId": tracker.id, "isCompleted": isCompleted])
    }
    
}

class HeaderView: UICollectionReusableView {
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
