//
//  StatisticViewController.swift
//  Tracker
//
//  Created by GiyaDev on 05.05.2024.
//

import Foundation
import UIKit

final class StatisticViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupUI() {
        title = NSLocalizedString("Статистика", comment: "Заголовок экрана статистики")
        view.backgroundColor = ThemeManager.shared.backgroundColor()
    }
}
