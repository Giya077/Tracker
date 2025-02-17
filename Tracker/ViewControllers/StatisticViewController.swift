//
//  StatisticViewController.swift
//  Tracker
//
//  Created by GiyaDev on 05.05.2024.
//

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
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var stubView: StubView!
    private let trackerRecordStore: TrackerRecordStore
    
    init(trackerRecordStore: TrackerRecordStore) {
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .trackerRecordsDidChange, object: nil)
        print("StatisticViewController deinitialized")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.backgroundColor()
        setupHeader()
        setupCollectionView()
        setupStubView()
        updateUI()
        updateStatisticsView()
        NotificationCenter.default.addObserver(self, selector: #selector(trackerRecordsDidChange(_:)), name: .trackerRecordsDidChange, object: nil)
    }
    
    private func setupHeader() {
        view.addSubview(statisticsHeaderLabel)
        NSLayoutConstraint.activate([
            statisticsHeaderLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statisticsHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.register(GradientBorderCell.self, forCellWithReuseIdentifier: "StatsCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = ThemeManager.shared.backgroundColor()
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: statisticsHeaderLabel.bottomAnchor, constant: 20),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupStubView() {
        stubView = StubView(text: NSLocalizedString("Nothing to analyze yet", comment: "Анализировать пока нечего"))
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
        collectionView.isHidden = totalCompleted == 0
        collectionView.reloadData()
    }
    
    private func formattedBestPeriod() -> String {
        guard let bestPeriodCount = trackerRecordStore.bestPeriod() else {
            return NSLocalizedString("No data", comment: "Нет данных")
        }
        return "\(bestPeriodCount)"
    }

    
    private func updateStatisticsView() {
        let records = trackerRecordStore.fetchAllRecords()
        if records.isEmpty {
            stubView.isHidden = false
            collectionView.isHidden = true
        } else {
            stubView.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    @objc
    private func trackerRecordsDidChange(_ notification: Notification) {
        print("Received notification in StatisticViewController")
        DispatchQueue.main.async {
            self.updateStatisticsView()
            self.updateUI()
        }
    }
}

extension StatisticViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCell", for: indexPath) as! GradientBorderCell
        switch indexPath.item {
        case 0:
            cell.configure(title: formattedBestPeriod(), subtitle: NSLocalizedString("Best Period", comment: "Лучший период"))
        case 1:
            cell.configure(title: "\(trackerRecordStore.idealDays())", subtitle: NSLocalizedString("Ideal Days", comment: "Идеальные дни"))
        case 2:
            cell.configure(title: "\(trackerRecordStore.completedTrackersCount())", subtitle: NSLocalizedString("Trackers Completed", comment: "Трекеров завершено"))
        case 3:
            cell.configure(title: "\(trackerRecordStore.averageCompletedTrackers())", subtitle: NSLocalizedString("Average Completed", comment: "Среднее значение"))
        default:
            break
        }
        return cell
    }
}

extension StatisticViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 0
        let width = collectionView.frame.width - padding
        return CGSize(width: width, height: 90)
    }
}
