//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by GiyaDev on 10.05.2024.
//

import UIKit

final class NewTrackerViewController: UIViewController {
        
    weak var delegate: NewTrackerDelegate?
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private lazy var habitButton: UIButton = {
        let habitButton = BasicButton(title: NSLocalizedString("Habit", comment: "Привычка"))
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        return habitButton
    }()
    
    private lazy var irregularEvent: UIButton = {
        let irregularEvent = BasicButton(title: NSLocalizedString("Irregular event", comment: "Нерегулярные события"))
        irregularEvent.addTarget(self, action: #selector(irregularEventTapped), for: .touchUpInside)
        irregularEvent.translatesAutoresizingMaskIntoConstraints = false
        return irregularEvent
    }()
    
    private lazy var label: UILabel = {
        let label = BasicTextLabel(text: NSLocalizedString("Creating tracker", comment: "Создание трекера"))
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        stackView()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
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
        let habitViewController = HabitViewController(trackerCategoryStore: trackerCategoryStore)
        habitViewController.trackerDelegate = self
        habitViewController.trackerType = .habit
        navigationController?.pushViewController(habitViewController, animated: true)
        print("habbit button tapped")
    }
    
    @objc private func irregularEventTapped() {
        let irregularEventViewController = IrregularEventViewController(trackerCategoryStore: trackerCategoryStore)
        irregularEventViewController.trackerDelegate = self
        irregularEventViewController.trackerType = .event
        navigationController?.pushViewController(irregularEventViewController, animated: true)
        print("irregular button tapped")
    }
}

extension NewTrackerViewController: NewTrackerDelegate {
    func didFinishCreatingTracker(trackerType: TrackerType) {
        dismiss(animated: true) {
            print("Трекер типа \(trackerType) был успешно создан.")
        }
    }
}
