//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by GiyaDev on 10.05.2024.
//

import Foundation
import UIKit

protocol NewTrackerDelegate: AnyObject {
    func addTrackerToCompleted(trackRecord: TrackerRecord)}

final class NewTrackerViewController: UIViewController {
    
    weak var delegate: NewTrackerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        let habitButton = UIButton(type: .system)
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        habitButton.backgroundColor = .white
        habitButton.tintColor = .black
        habitButton.layer.cornerRadius = 8
        habitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        habitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let irregularEvent = UIButton(type: .system)
        irregularEvent.setTitle("Нерегулярные события", for: .normal)
        irregularEvent.addTarget(self, action: #selector(irregularEventTapped), for: .touchUpInside)
        irregularEvent.backgroundColor = .white
        irregularEvent.tintColor = .black
        irregularEvent.layer.cornerRadius = 8
        irregularEvent.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        irregularEvent.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let stackView = UIStackView(arrangedSubviews: [habitButton,irregularEvent])
        stackView.axis = .vertical
        stackView.spacing = 16
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
        ])
    }
    
    @objc func habitButtonTapped() {
        print("habbit button tapped")
    }
    
    @objc func irregularEventTapped() {
        print("irregular button tapped")
    }
}
