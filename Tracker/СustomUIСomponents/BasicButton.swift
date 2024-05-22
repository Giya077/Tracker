//
//  BasicButton.swift
//  Tracker
//
//  Created by GiyaDev on 22.05.2024.
//

import UIKit


final class BasicButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        
        backgroundColor = .black
        tintColor = .white
        layer.cornerRadius = 16
        titleLabel?.font = UIFont.systemFont(ofSize: 18)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4
        
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        setTitle(title, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
