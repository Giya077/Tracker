

import UIKit

extension UIColor {
    func isEqualToColor(_ otherColor: UIColor) -> Bool {
        var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
        var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0

        self.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        otherColor.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return abs(red1 - red2) < 0.001 &&
        abs(green1 - green2) < 0.001 &&
        abs(blue1 - blue2) < 0.001 &&
        abs(alpha1 - alpha2) < 0.001
    }
}
