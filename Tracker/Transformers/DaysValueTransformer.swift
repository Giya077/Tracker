////
////  DaysValueTransformer.swift
////  Tracker
////
////  Created by GiyaDev on 13.06.2024.
////
//
//import Foundation
//
//@objc(ScheduleValueTransformer)
//final class ScheduleValueTransformer: ValueTransformer {
//    override class func transformedValueClass() -> AnyClass { NSData.self }
//    override class func allowsReverseTransformation() -> Bool { true }
//    
//    override func transformedValue(_ value: Any?) -> Any? {
//        guard let days = value as? [Days] else { return nil }
//        do {
//            let data = try JSONEncoder().encode(days)
//            print("Days transformed to data: \(data)")
//            return data
//        } catch {
//            print("Failed to transform days to data: \(error)")
//            return nil
//        }
//    }
//    
//    override func reverseTransformedValue(_ value: Any?) -> Any? {
//        guard let data = value as? Data else { return nil }
//        do {
//            let days = try JSONDecoder().decode([Days].self, from: data)
//            print("Data transformed to days: \(days)")
//            return days
//        } catch {
//            print("Failed to transform data to days: \(error)")
//            return nil
//        }
//    }
//}
