//
//  TodoItem+CoreDataClass.swift
//  SoDoIt
//
//  Created by 한소희 on 2/8/26.
//

import Foundation
import CoreData

@objc(TodoItem)
public class TodoItem: NSManagedObject {

    nonisolated public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(UUID(), forKey: "id")
        setPrimitiveValue(Date(), forKey: "createdAt")
    }
}
