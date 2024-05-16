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
    
    private let habitButton: UIButton = {
        let habitButton = UIButton(type: .system)
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        habitButton.backgroundColor = .black
        habitButton.tintColor = .white
        habitButton.layer.cornerRadius = 10
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        habitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        habitButton.layer.shadowColor = UIColor.black.cgColor
        habitButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        habitButton.layer.shadowOpacity = 0.5
        habitButton.layer.shadowRadius = 4
        
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        return habitButton
    }()
    
    private let irregularEvent: UIButton = {
        let irregularEvent = UIButton(type: .system)
        irregularEvent.setTitle("Нерегулярные события", for: .normal)
        irregularEvent.addTarget(self, action: #selector(irregularEventTapped), for: .touchUpInside)
        irregularEvent.backgroundColor = .black
        irregularEvent.tintColor = .white
        irregularEvent.layer.cornerRadius = 10
        irregularEvent.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        irregularEvent.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        irregularEvent.layer.shadowColor = UIColor.black.cgColor
        irregularEvent.layer.shadowOffset = CGSize(width: 0, height: 2)
        irregularEvent.layer.shadowOpacity = 0.5
        irregularEvent.layer.shadowRadius = 4
        
        irregularEvent.translatesAutoresizingMaskIntoConstraints = false
        return irregularEvent
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(label)
        setupUI()
        stackView()
    }
    
    private func setupUI() {
        
        //LABEL
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func stackView() {
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
    
    @objc private func habitButtonTapped() {
        let habitViewController = HabitViewController()
        let nav = UINavigationController(rootViewController: habitViewController)
        present(nav, animated: true)
        print("habbit button tapped")
    }
    
    @objc private func irregularEventTapped() {
        let irregularEventViewController = IrregularEventViewController()
        let nav = UINavigationController(rootViewController: irregularEventViewController)
        present(nav, animated:  true)
        print("irregular button tapped")
    }
}
