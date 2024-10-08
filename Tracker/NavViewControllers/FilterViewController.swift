//
//  FilterViewController.swift
//  Tracker
//
//  Created by GiyaDev on 05.10.2024.
//

import UIKit


protocol FilterDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

enum TrackerFilter: String {
    case all = "All Trackers"
    case today = "Trackers for Today"
    case completed = "Completed"
    case notCompleted = "Not Completed"
}

final class FilterViewController: UIViewController {
    
    weak var delegate: FilterDelegate?
    
    private let filters: [TrackerFilter] = [.all, .today, .completed, .notCompleted]
    private let filtersLocal = [
        NSLocalizedString("All Trackers", comment: "Все трекеры"),
        NSLocalizedString("Trackers for Today", comment: "Трекеры на сегодня"),
        NSLocalizedString("Completed", comment: "Завершенные"),
        NSLocalizedString("Not Completed", comment: "Не завершенные")
    ]
    
    private var selectedFilter: TrackerFilter
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = ThemeManager.shared.backgroundColor()
        return tableView
    }()
    
    init(delegate: FilterDelegate? = nil, selectedFilter: TrackerFilter) {
        self.delegate = delegate
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var label: UILabel = {
        let label = BasicTextLabel(text: NSLocalizedString("Filters", comment: "Фильтры"))
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = ThemeManager.shared.backgroundColor()
        view.addSubview(label)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        let filter = filters[indexPath.row]
        let filterName = filtersLocal[indexPath.row]
        
        cell.textLabel?.text = filterName
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.accessoryType = filter == selectedFilter ? .checkmark : .none
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFilter = filters[indexPath.row]
        delegate?.didSelectFilter(selectedFilter)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
