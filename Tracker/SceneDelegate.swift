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
        
        window = UIWindow(windowScene: windowScene)
        
        if shouldsShowOnboarding() {
            let onboardingVC = OnboardingViewController()
            onboardingVC.onboardingCompleted = {
                self.showMainApp()
            }
            window?.rootViewController = onboardingVC
        } else {
            showMainApp()
        }
        window?.makeKeyAndVisible()
    }
    
    private func shouldsShowOnboarding() -> Bool {
        return !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
    
    private func showMainApp() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Unable to access AppDelegate")
            return
        }
        
        let context = appDelegate.persistantContainer.viewContext
        
        let tabBarController = UITabBarController()
        
        let trackerStore = TrackerStore(context: context)
        let trackerCategoryStore = TrackerCategoryStore(context: context)
        let trackerRecordStore = TrackerRecordStore(context: context)
        
        let trackerViewController = TrackerViewController(trackerStore: trackerStore, trackerCategoryStore: trackerCategoryStore, trackerRecordStore: trackerRecordStore)
        let statisticViewController = StatisticViewController(trackerRecordStore: trackerRecordStore)
        
        let trackNav = UINavigationController(rootViewController: trackerViewController)
        let statisticNav = UINavigationController(rootViewController: statisticViewController)
        
        trackNav.tabBarItem = UITabBarItem(
             title: NSLocalizedString("Trackers", comment: "Title for the Trackers tab"),
             image: UIImage(systemName: "record.circle.fill"),
             tag: 0
           )
             statisticNav.tabBarItem = UITabBarItem(
                 title: NSLocalizedString("Statistics", comment: "Title for the Statistics tab"),
                 image: UIImage(systemName: "hare.fill"),
                 tag: 1
             )   
        tabBarController.viewControllers = [trackNav, statisticNav]
        
        window?.rootViewController = tabBarController
        
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

