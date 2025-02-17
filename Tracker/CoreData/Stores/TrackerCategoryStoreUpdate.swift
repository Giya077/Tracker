//
//  TrackerCategoryStoreUpdate.swift
//  Tracker
//
//  Created by GiyaDev on 27.06.2024.
//

import Foundation

struct TrackerCategoryStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let movedIndexes: Set<Move>
}
