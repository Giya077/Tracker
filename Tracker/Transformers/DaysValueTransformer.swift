//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by GiyaDev on 13.06.2024.
//

import Foundation

@objc(DaysValueTransformer)
final class DaysValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [Days] else { return nil }
        return try? JSONEncoder().encode(days)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        return try? JSONDecoder().decode([Days].self, from: data)
    }
}
