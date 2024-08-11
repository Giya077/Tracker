//
//  EmojiCellHelper.swift
//  Tracker
//
//  Created by GiyaDev on 15.05.2024.
//

import Foundation
import UIKit

class EmojiCell: UICollectionViewCell {
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectedPlaceholder: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.systemSearchColor
        view.layer.cornerRadius = 10
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
    
    func setSelected( _ selected: Bool) {
        selectedPlaceholder.isHidden = !selected
    }

    private func setupUI() {
        contentView.addSubview(selectedPlaceholder)
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            
            selectedPlaceholder.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectedPlaceholder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectedPlaceholder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectedPlaceholder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            emojiLabel.centerXAnchor.constraint(equalTo: selectedPlaceholder.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: selectedPlaceholder.centerYAnchor)
        ])
    }
}
