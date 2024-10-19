

import UIKit

class ThemeManager {
    static let shared = ThemeManager()

    private init() {}

    func backgroundColor() -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(named: "darkThemeColor") ?? .black : .systemBackground
        }
    }

    func textColor() -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
    }
    
    func buttonBackgroundColor() -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
    }
    
    func buttonTextColor() -> UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .white
        }
    }
    
    func emojiPlaceholderColor() -> UIColor {
        return UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .white
            } else {
                return Colors.systemSearchColor ?? .lightGray
            }
        }
    }
}
