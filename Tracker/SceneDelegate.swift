//
//  SceneDelegate.swift
//  Tracker
//
//  Created by GiyaDev on 05.05.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Unable to access AppDelegate")
            return
        }
        
        let context = appDelegate.persistantContainer.viewContext
        
        let window = UIWindow(windowScene: windowScene)
        let tabBarController = UITabBarController()
        let trackerStore = TrackerStore(context: context)
        let trackerCategoryStore = TrackerCategoryStore(context: context)
        let trackerViewController = TrackerViewController(trackerStore: trackerStore, trackerCategoryStore: trackerCategoryStore)
        let statisticViewController = StatisticViewController()
        let trackNav = UINavigationController(rootViewController: trackerViewController)
        let statisticNav = UINavigationController(rootViewController: statisticViewController)
        trackNav.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(systemName: "record.circle.fill"), tag: 0)
        statisticNav.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "hare.fill"), tag: 1)
        tabBarController.viewControllers = [trackNav, statisticNav]
        
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
        
        let tabBarTopLine = UIView()
        tabBarTopLine.backgroundColor = UIColor.lightGray
        tabBarController.tabBar.addSubview(tabBarTopLine)
        tabBarTopLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tabBarTopLine.topAnchor.constraint(equalTo: tabBarController.tabBar.topAnchor),
            tabBarTopLine.leadingAnchor.constraint(equalTo: tabBarController.tabBar.leadingAnchor),
            tabBarTopLine.trailingAnchor.constraint(equalTo: tabBarController.tabBar.trailingAnchor),
            tabBarTopLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
}

