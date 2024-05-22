//
//  StubView.swift
//  Tracker
//
//  Created by GiyaDev on 17.05.2024.
//

import Foundation
import UIKit

final class StubView: UIView {
    
    private let vStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    let textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        textLabel.textAlignment = .center
        textLabel.textColor = .black
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    private let stubImage: UIImageView = {
        let stub = UIImage(named: "stubView")
        let stubImage = UIImageView(image: stub)
        stubImage.contentMode = .scaleAspectFit
        stubImage.translatesAutoresizingMaskIntoConstraints = false
        return stubImage
    }()
    
    init(text: String) {
        super.init(frame: .zero)
        
        textLabel.text = text
        setupStubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStubView() {
        translatesAutoresizingMaskIntoConstraints = false
        vStack.addArrangedSubview(stubImage)
        vStack.addArrangedSubview(textLabel)
        
        addSubview(vStack)
        
        
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            vStack.topAnchor.constraint(equalTo: topAnchor),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stubImage.heightAnchor.constraint(equalToConstant: 100),
            stubImage.widthAnchor.constraint(equalToConstant: 100),
            
            textLabel.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: vStack.trailingAnchor)
        ])
    }
}
