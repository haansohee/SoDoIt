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
    ) throws -> TodoItem {
        let todo = TodoItem(context: context)
        todo.title = title
        todo.memo = memo
        todo.dueDate = dueDate
        todo.priority = priority.rawValue
        todo.category = category
        do {
            try save()
        } catch {
            context.rollback()
            throw error
        }
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
        do { try save() } catch { print("CoreData 저장 실패: \(error)") }
    }

    func toggleTodoCompletion(_ todo: TodoItem) {
        todo.isCompleted.toggle()
        todo.completedAt = todo.isCompleted ? Date() : nil
        do { try save() } catch { print("CoreData 저장 실패: \(error)") }
    }

    func deleteTodo(_ todo: TodoItem) {
        context.delete(todo)
        do { try save() } catch { print("CoreData 저장 실패: \(error)") }
    }

    // MARK: - Private
    private func save() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
