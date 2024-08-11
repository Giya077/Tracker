//
//  BasicTextLabel.swift
//  Tracker
//
//  Created by GiyaDev on 22.05.2024.
//

import UIKit

final class BasicTextLabel: UILabel {
    init(text: String) {
        super.init(frame: .zero)
        
        font = UIFont.boldSystemFont(ofSize: 18)
        textColor = .black
        translatesAutoresizingMaskIntoConstraints = false
        self.text = text
        
    }
    required init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
}
