//
//  Category+CoreDataProperties.swift
//  SoDoIt
//
//  Created by 한소희 on 2/8/26.
//

import Foundation
import CoreData

extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var colorHex: String?
    @NSManaged public var iconName: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var todoItems: NSSet?
}

// MARK: - Generated accessors for todoItems
extension Category {

    @objc(addTodoItemsObject:)
    @NSManaged public func addToTodoItems(_ value: TodoItem)

    @objc(removeTodoItemsObject:)
    @NSManaged public func removeFromTodoItems(_ value: TodoItem)

    @objc(addTodoItems:)
    @NSManaged public func addToTodoItems(_ values: NSSet)

    @objc(removeTodoItems:)
    @NSManaged public func removeFromTodoItems(_ values: NSSet)
}

extension Category: Identifiable {

    var wrappedName: String {
        name ?? ""
    }

    var wrappedColorHex: String {
        colorHex ?? "#007AFF"
    }

    var wrappedIconName: String {
        iconName ?? "folder.fill"
    }

    var wrappedId: UUID {
        id ?? UUID()
    }

    var todoItemsArray: [TodoItem] {
        let set = todoItems as? Set<TodoItem> ?? []
        return set.sorted { ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) }
    }

    var activeTodoCount: Int {
        todoItemsArray.filter { !$0.isCompleted }.count
    }
}
