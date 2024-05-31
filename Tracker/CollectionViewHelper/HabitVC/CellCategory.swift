
//  CellCategory.swift
//  Tracker
//
//  Created by GiyaDev on 21.05.2024.


import Foundation
import UIKit

class CategoryCell: UITableViewCell {
    
    private let customBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        backgroundColor = .white
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(customBackgroundView)
        customBackgroundView.addSubview(categoryLabel)
        
        NSLayoutConstraint.activate([
            customBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            customBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            customBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            customBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            categoryLabel.topAnchor.constraint(equalTo: customBackgroundView.topAnchor, constant: 16),
            categoryLabel.leadingAnchor.constraint(equalTo: customBackgroundView.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: customBackgroundView.trailingAnchor, constant: -16),
            categoryLabel.bottomAnchor.constraint(equalTo: customBackgroundView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(withTitle title: String, backgroundColor: UIColor, isSelected: Bool) {
        categoryLabel.text = title
        customBackgroundView.backgroundColor = backgroundColor
        accessoryType = isSelected ? .checkmark : .none
    }
}
