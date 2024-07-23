//
//  Colors:Schedule.swift
//  Tracker
//
//  Created by GiyaDev on 23.07.2024.
//

import UIKit

 class ColorTransformedToData {
    func hexString(from color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        return String.init(
            format: "%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }
    
    func color(from hex: String) -> UIColor {
        var rgbValue:UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

 class ScheduleTransformedToData {
    private let weekdays: [String] = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    func makeStringFromArray(_ timetable: [String]) -> String {
        var string = ""
        for day in weekdays {
            if timetable.contains(day) {
                string += "1"
            } else {
                string += "0"
            }
        }
        return string
    }
    
    func makeWeekDayArrayFromString(_ timetable: String?) -> [String] {
        var array: [String] = []
        if let timetable = timetable {
            timetable.enumerated().forEach { index, character in
                if character == "1" {
                    array.append(weekdays[index])
                }
            }
        }
        return array
    }
}
