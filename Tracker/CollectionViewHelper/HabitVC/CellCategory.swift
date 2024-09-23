
//  CellCategory.swift
//  Tracker
//
//  Created by GiyaDev on 21.05.2024.


import Foundation
import UIKit

class CategoryCell: UITableViewCell {
    
    var onLongPress: (() -> Void)?
    
    private var isSelectedCell: Bool = false
    
    private let customBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemSearchColor
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeManager.shared.textColor()
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkMarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.tintColor = UIColor.label
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        backgroundColor = Colors.systemSearchColor
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .clear
        addLongPressGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
    
    private func setupView() {
        contentView.addSubview(customBackgroundView)
        customBackgroundView.addSubview(categoryLabel)
        customBackgroundView.addSubview(checkMarkImageView)
        
        NSLayoutConstraint.activate([
            customBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            customBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            customBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            customBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            categoryLabel.topAnchor.constraint(equalTo: customBackgroundView.topAnchor, constant: 16),
            categoryLabel.leadingAnchor.constraint(equalTo: customBackgroundView.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: customBackgroundView.trailingAnchor, constant: -16),
            categoryLabel.bottomAnchor.constraint(equalTo: customBackgroundView.bottomAnchor, constant: -16),
            
            checkMarkImageView.trailingAnchor.constraint(equalTo: customBackgroundView.trailingAnchor, constant: -16),
            checkMarkImageView.centerYAnchor.constraint(equalTo: customBackgroundView.centerYAnchor),
            checkMarkImageView.widthAnchor.constraint(equalToConstant: 14),
            checkMarkImageView.heightAnchor.constraint(equalToConstant: 14)
            
        ])
    }
        
    private func updateCheckmarkVisibility() {
        checkMarkImageView.isHidden = !isSelectedCell
    }
    
    private func addLongPressGestureRecognizer() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc
    private func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            onLongPress?()
        }
    }
    
    func configure(withTitle title: String, backgroundColor: UIColor, isSelected: Bool) {
        categoryLabel.text = title
        customBackgroundView.backgroundColor = ThemeManager.shared.backgroundColor()
        isSelectedCell = isSelected
        updateCheckmarkVisibility()
    }
}
