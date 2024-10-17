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
    
    private let colorTransformedToData = ColorTransformedToData()
    private let scheduleTransformedToData = ScheduleTransformedToData()
    
    lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private func printAllTrackers() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            let results = try persistantContainer.viewContext.fetch(fetchRequest)
            for result in results {
                print("Tracker ID: \(result.id ?? UUID()), Name: \(result.name ?? "No Name"), Color: \(result.color ?? "No Color"), Emoji: \(result.emoji ?? "No Emoji"), Schedule: \(result.schedule ?? "No Schedule")")
            }
            print("Number of trackers: \(results.count)")
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "f1b4973d-43ff-40be-94b0-0ec95c61c693") else {
//            printAllTrackers()
//            return true
//        }
//        YMMYandexMetrica.activate(with: configuration)
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

