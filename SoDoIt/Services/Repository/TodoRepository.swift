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
    ) throws {
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
    }

    func toggleTodoCompletion(_ todo: TodoItem) throws {
        todo.isCompleted.toggle()
        todo.completedAt = todo.isCompleted ? Date() : nil
        do {
            try save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func deleteTodo(_ todo: TodoItem) throws {
        context.delete(todo)
        do {
            try save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func deleteAllTodos() throws {
        let request: NSFetchRequest<NSFetchRequestResult> = TodoItem.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
        batchDelete.resultType = .resultTypeObjectIDs
        do {
            let result = try context.execute(batchDelete) as? NSBatchDeleteResult
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            }
        } catch {
            context.rollback()
            throw error
        }
    }

    // MARK: - Private
    private func save() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
