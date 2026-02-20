//
//  TodoRepository.swift
//  SoDoIt
//
//  Created by 한소희 on 2/19/26.
//

import Foundation
import CoreData

final class TodoRepository {
    // MARK: - TodoItem CRUD
    @discardableResult
    func createTodo(
        title: String,
        memo: String? = nil,
        dueDate: Date? = nil,
        priority: Priority = .medium,
        category: Category? = nil
    ) -> TodoItem {
        let todo = TodoItem(context: CoreDataManager.shared.viewContext)
        todo.title = title
        todo.memo = memo
        todo.dueDate = dueDate
        todo.priority = priority.rawValue
        todo.category = category
        CoreDataManager.shared.save()
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
        CoreDataManager.shared.save()
    }
    
    func toggleTodoCompletion(_ todo: TodoItem) {
        todo.isCompleted.toggle()
        todo.completedAt = todo.isCompleted ? Date() : nil
        CoreDataManager.shared.save()
    }
    
    func deleteTodo(_ todo: TodoItem) {
        CoreDataManager.shared.viewContext.delete(todo)
        CoreDataManager.shared.save()
    }}
