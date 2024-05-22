//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by GiyaDev on 14.05.2024.
//

import Foundation
import UIKit

class ScheduleViewController: UIViewController {
    
    weak var delegate: TimetableDelegate?
    private let days: [Days] = [.monday,.tuesday,.wednesday,.thursday,.friday,.saturday,.sunday]
    private let daysRu = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    private var selectedDays: Set<Days>
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(TimetableTableViewCell.self, forCellReuseIdentifier: "DaysCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        return tableView
    }()
    
    init(delegate: TimetableDelegate? = nil, selectedDays: Set<Days>) {
        self.delegate = delegate
        self.selectedDays = selectedDays
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let scheduleLabel: UILabel = {
        let scheduleLabel = UILabel()
        scheduleLabel.text = "Новая привычка"
        scheduleLabel.textColor = .black
        scheduleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        scheduleLabel.translatesAutoresizingMaskIntoConstraints = false
        return scheduleLabel
    }()
    
    private let doneButton: UIButton = {
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Готово", for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.backgroundColor = .black
        doneButton.tintColor = .white
        doneButton.layer.cornerRadius = 12
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        doneButton.layer.shadowColor = UIColor.black.cgColor
        doneButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        doneButton.layer.shadowOpacity = 0.5
        doneButton.layer.shadowRadius = 4
        return doneButton
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(scheduleLabel)
        view.addSubview(doneButton)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            scheduleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            scheduleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            doneButton.heightAnchor.constraint(equalToConstant: 75),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: scheduleLabel.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -10),
        ])
    }
    
    @objc
    private func doneButtonTapped() {
        delegate?.didUpdateSelectedDays(selectedDays)
        dismiss(animated: true, completion: nil)
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DaysCell", for: indexPath) as! TimetableTableViewCell
        cell.configure(dayName: daysRu[indexPath.row], isSelected: selectedDays.contains(days[indexPath.row]))
        cell.switchView.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else {
            return
        }
        
        let selectedDay = days[indexPath.row]
        
        if sender.isOn {
            selectedDays.insert(selectedDay)
        } else {
            selectedDays.remove(selectedDay)
        }
    }
}

