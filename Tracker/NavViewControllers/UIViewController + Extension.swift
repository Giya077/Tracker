import UIKit

extension UIViewController {
    
    func updateTrackerLabel(_ label: UILabel, isEditingTracker: Bool, trackerType: TrackerType?) {
        if isEditingTracker {
            label.text = trackerType == .habit ? NSLocalizedString("Edit habit", comment: "Редактирование привычки") : NSLocalizedString("Edit event", comment: "Редактирование события")
        } else {
            label.text = trackerType == .habit ? NSLocalizedString("New habit", comment: "Новая привычка") : NSLocalizedString("New event", comment: "Новое событие")
        }
    }
}
