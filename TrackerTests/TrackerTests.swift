import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    override func setUpWithError() throws {
        SnapshotTesting.isRecording = false
    }

    func testTrackerViewControllerLightMode() {
        let tabBarController = createTabBarController()
        let lightTraitCollection = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(of: tabBarController, as: .image(on: .iPhone13Pro, traits: lightTraitCollection))
    }

    func testTrackerViewControllerDarkMode() {
        let tabBarController = createTabBarController()
        let darkTraitCollection = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(of: tabBarController, as: .image(on: .iPhone13Pro, traits: darkTraitCollection))
    }

    func createTabBarController() -> UITabBarController {
        let trackerStore = MockTrackerStore()
        let trackerCategoryStore = MockTrackerCategoryStore()
        let trackerRecordStore = MockTrackerRecordStore()
        
        let trackerViewController = TrackerViewController(trackerStore: trackerStore, trackerCategoryStore: trackerCategoryStore, trackerRecordStore: trackerRecordStore)
        let statisticViewController = StatisticViewController(trackerRecordStore: trackerRecordStore)

        let trackNav = UINavigationController(rootViewController: trackerViewController)
        let statisticNav = UINavigationController(rootViewController: statisticViewController)

        let trackImage = UIImage(systemName: "record.circle.fill") ?? UIImage(named: "track_fallback_image")
        trackNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Trackers", comment: "Title for the Trackers tab"),
            image: trackImage,
            tag: 0
        )

        let statisticImage = UIImage(systemName: "hare.fill") ?? UIImage(named: "statistic_fallback_image")
        statisticNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Statistics", comment: "Title for the Statistics tab"),
            image: statisticImage,
            tag: 1
        )

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [trackNav, statisticNav]
        tabBarController.tabBar.layoutIfNeeded()

        return tabBarController
    }
}
