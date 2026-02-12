//
//  TodoItem+CoreDataProperties.swift
//  SoDoIt
//
//  Created by 한소희 on 2/8/26.
//

import Foundation
import CoreData

extension TodoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItem> {
        return NSFetchRequest<TodoItem>(entityName: "TodoItem")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var memo: String?
    @NSManaged public var dueDate: Date?
    @NSManaged public var priority: Int16
    @NSManaged public var isCompleted: Bool
    @NSManaged public var completedAt: Date?
    @NSManaged public var createdAt: Date
    @NSManaged public var category: Category?
}

extension TodoItem: Identifiable {

    var wrappedMemo: String {
        memo ?? ""
    }

    var priorityLevel: Priority {
        Priority(rawValue: priority) ?? .medium
    }

    var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        return dueDate < Date() && !Calendar.current.isDateInToday(dueDate)
    }
}
