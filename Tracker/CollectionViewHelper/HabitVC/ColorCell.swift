//
//  ColorCell.swift
//  Tracker
//
//  Created by GiyaDev on 29.05.2024.
//

import Foundation
import UIKit

class ColorCell: UICollectionViewCell {
    
    private let colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.masksToBounds = true
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
        layer.cornerRadius = 10
        backgroundColor = ThemeManager.shared.backgroundColor()
    }
    
    required init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
    
    private func setupViews() {
        contentView.addSubview(borderView)
        borderView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            colorView.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 4),
            colorView.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 4),
            colorView.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -4),
            colorView.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -4)
        ])
    }
    
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }
    
    func setSelected( _ selected: Bool) {
        borderView.layer.borderColor = selected ? colorView.backgroundColor?.cgColor : UIColor.clear.cgColor
    }
}
