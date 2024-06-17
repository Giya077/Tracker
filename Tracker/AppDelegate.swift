//
//  AppDelegate.swift
//  Tracker
//
//  Created by GiyaDev on 05.05.2024.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerScheduleValueTransformer()
        registerColorValueTransformer()
        return true
    }
    
    private func registerScheduleValueTransformer() {
        let transformer = ScheduleValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName(rawValue: String(describing: ScheduleValueTransformer().self)))
    }
    
    private func registerColorValueTransformer() {
        let transformer = ColorValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName(rawValue: String(describing: ColorValueTransformer.self)))
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

