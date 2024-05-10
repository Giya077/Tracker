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

        let window = UIWindow(windowScene: windowScene)
        let tabBarController = UITabBarController()
        let trackerViewController = TrackerViewController()
        let statisticViewController = StatisticViewController()
        let trackNav = UINavigationController(rootViewController: trackerViewController)
        let statisticNav = UINavigationController(rootViewController: statisticViewController)
        trackNav.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(systemName: "record.circle.fill"), tag: 0)
        statisticNav.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "hare.fill"), tag: 1)
        tabBarController.viewControllers = [trackNav, statisticNav]

        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }


}

