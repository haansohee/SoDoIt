//
//  TodoRepository.swift
//  SoDoIt
//
//  Created by 한소희 on 2/19/26.
//

import Foundation
import CoreData

final class TodoRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.context = context
    }

    // MARK: - TodoItem CRUD
    @discardableResult
    func createTodo(
        title: String,
        memo: String? = nil,
        dueDate: Date? = nil,
        priority: Priority = .medium,
        category: Category? = nil
    ) -> TodoItem {
        let todo = TodoItem(context: context)
        todo.title = title
        todo.memo = memo
        todo.dueDate = dueDate
        todo.priority = priority.rawValue
        todo.category = category
        save()
        return todo
    }

    func updateTodo(
        _ todo: TodoItem,
        title: String,
        memo: String?,
        dueDate: Date?,
        priority: Priority,
        category: Category?
    ) {
        todo.title = title
        todo.memo = memo
        todo.dueDate = dueDate
        todo.priority = priority.rawValue
        todo.category = category
        save()
    }

    func toggleTodoCompletion(_ todo: TodoItem) {
        todo.isCompleted.toggle()
        todo.completedAt = todo.isCompleted ? Date() : nil
        save()
    }

    func deleteTodo(_ todo: TodoItem) {
        context.delete(todo)
        save()
    }

    // MARK: - Private
    private func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("CoreData 저장 실패: \(error)")
        }
    }
}
