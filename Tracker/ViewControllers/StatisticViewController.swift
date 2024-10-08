//
//  StatisticViewController.swift
//  Tracker
//
//  Created by GiyaDev on 05.05.2024.
//

import Foundation
import UIKit

final class StatisticViewController: UIViewController {
    
    private let statisticsHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Statistics", comment: "Заголовок для экрана статистики")
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView = UITableView()
    private var stubView: StubView!
    private let trackerRecordStore: TrackerRecordStore
    
    init(trackerRecordStore: TrackerRecordStore) {
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.backgroundColor()
        setupHeader()
        setupTableView()
        setupStubView()
        updateUI()
    }
    
    private func setupHeader() {
        view.addSubview(statisticsHeaderLabel)
        NSLayoutConstraint.activate([
            statisticsHeaderLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statisticsHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StatsCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupStubView() {
        stubView = StubView(text: NSLocalizedString("Анализировать пока нечего", comment: "Текст для пустого экрана статистики"))
        if let statisticStubImage = UIImage(named: "statisticStubView") {
            stubView.updateImage(statisticStubImage)
        }
        stubView.isHidden = true
        view.addSubview(stubView)
        
        NSLayoutConstraint.activate([
            stubView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateUI() {
        let totalCompleted = trackerRecordStore.completedTrackersCount()
        stubView.isHidden = totalCompleted > 0
        tableView.isHidden = totalCompleted == 0
        tableView.reloadData()
    }
    
    private func formattedBestPeriod() -> String {
        guard let bestPeriod = trackerRecordStore.bestPeriod() else {
            return NSLocalizedString("No data", comment: "Нет данных")
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: bestPeriod.start)) - \(formatter.string(from: bestPeriod.end))"
    }
    
    private func updateStatisticsView() {
        let records = trackerRecordStore.fetchAllRecords()
        if records.isEmpty {
            stubView.isHidden = false
            tableView.isHidden = true
        } else {
            stubView.isHidden = true
            tableView.isHidden = false
        }
    }
}

extension StatisticViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatsCell", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("Best Period", comment: "Лучший период") + ": " + formattedBestPeriod()
        case 1:
            cell.textLabel?.text = NSLocalizedString("Ideal Days", comment: "Идеальные дни") + ": \(trackerRecordStore.idealDays())"
        case 2:
            cell.textLabel?.text = NSLocalizedString("Trackers Completed", comment: "Трекеров завершено") + ": \(trackerRecordStore.completedTrackersCount())"
        case 3:
            cell.textLabel?.text = NSLocalizedString("Average Completed", comment: "Среднее значение") + ": \(trackerRecordStore.averageCompletedTrackers())"
        default:
            break
        }
        return cell
    }
}

extension StatisticViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

