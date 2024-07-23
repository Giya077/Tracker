//
//  ColorValueTransformer.swift
//  Tracker
//
//  Created by GiyaDev on 16.06.2024.
//

//import UIKit
//
//@objc(ColorValueTransformer)
//final class ColorValueTransformer: ValueTransformer {
//    override class func transformedValueClass() -> AnyClass { NSData.self }
//    override class func allowsReverseTransformation() -> Bool { true }
//    
//    override func transformedValue(_ value: Any?) -> Any? {
//        guard let color = value as? UIColor else { return nil }
//        do {
//            let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
//            print("Color transformed to data: \(data)")
//            return data
//        } catch {
//            print("Failed to transform color to data: \(error)")
//            return nil
//        }
//    }
//    
//    override func reverseTransformedValue(_ value: Any?) -> Any? {
//        guard let data = value as? Data else { return nil }
//        do {
//            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
//            print("Data transformed to color: \(String(describing: color))")
//            return color
//        } catch {
//            print("Failed to transform data to color: \(error)")
//            return nil
//        }
//    }
//}
