//
//  EditTodoViewModel.swift
//  SoDoIt
//
//  Created by 한소희 on 3/12/26.
//

import Foundation
import CoreData

final class EditTodoViewModel: TodoFormViewModel {

    private let todo: TodoItem

    init(
        todo: TodoItem,
        repository: TodoRepository? = nil
    ) {
        let context = todo.managedObjectContext ?? CoreDataManager.shared.viewContext
        self.todo = todo

        // 기존 할 일 데이터로 formState 초기화
        var state = TodoFormState()
        state.title = todo.title
        state.memo = todo.wrappedMemo
        state.priority = todo.priorityLevel
        state.selectedCategory = todo.category
        if let dueDate = todo.dueDate {
            state.hasDueDate = true
            state.dueDate = dueDate
        }

        super.init(formState: state, context: context, repository: repository)
    }

    // MARK: - Actions

    func save() throws {
        do {
            try repository.updateTodo(
                todo,
                title: formState.title.trimmingCharacters(in: .whitespacesAndNewlines),
                memo: formState.memo.isEmpty ? nil : formState.memo,
                dueDate: formState.hasDueDate ? formState.dueDate : nil,
                priority: formState.priority,
                category: formState.selectedCategory
            )
            let notifications = NotificationManager.shared
            notifications.cancelNotification(for: todo.id)
            if formState.hasDueDate {
                notifications.scheduleDueDateNotification(
                    for: todo.id,
                    title: formState.title.trimmingCharacters(in: .whitespacesAndNewlines),
                    dueDate: formState.dueDate
                )
            }
        } catch {
            showSaveError = true
            throw error
        }
    }
}
