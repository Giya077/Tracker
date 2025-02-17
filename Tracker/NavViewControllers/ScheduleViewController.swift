//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by GiyaDev on 14.05.2024.
//

import Foundation
import UIKit

final class ScheduleViewController: UIViewController {
    
    weak var delegate: TimetableDelegate?
    private let days: [Days] = [.monday,.tuesday,.wednesday,.thursday,.friday,.saturday,.sunday]
    private let daysRu = [
        NSLocalizedString("Monday", comment: "Понедельник"),
        NSLocalizedString("Tuesday", comment: "Вторник"),
        NSLocalizedString("Wednesday", comment: "Среда"),
        NSLocalizedString("Thursday", comment: "Четверг"),
        NSLocalizedString("Friday", comment: "Пятница"),
        NSLocalizedString("Saturday", comment: "Суббота"),
        NSLocalizedString("Sunday", comment: "Воскресенье")
    ]
    
    private var selectedDays: Set<Days>
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(TimetableTableViewCell.self, forCellReuseIdentifier: "DaysCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = ThemeManager.shared.backgroundColor()
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return tableView
    }()
    
    init(delegate: TimetableDelegate? = nil, selectedDays: Set<Days>) {
        self.delegate = delegate
        self.selectedDays = selectedDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        print("init(coder:) has not been implemented")
        return nil
    }
    
    lazy var label: UILabel = {
        let label = BasicTextLabel(text: NSLocalizedString("Schedule", comment: "Расписание"))
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let doneButton = BasicButton(title: NSLocalizedString("Done", comment: "Готово"))
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        return doneButton
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.shared.backgroundColor()
        view.addSubview(label)
        view.addSubview(doneButton)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
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
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        
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

