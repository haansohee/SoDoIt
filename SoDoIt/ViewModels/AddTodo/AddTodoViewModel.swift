//
//  AddTodoViewModel.swift
//  SoDoIt
//
//  Created by 한소희 on 2/22/26.
//

import Foundation
import CoreData

final class AddTodoViewModel: TodoFormViewModel {

    init(
        context: NSManagedObjectContext = CoreDataManager.shared.viewContext,
        repository: TodoRepository? = nil
    ) {
        super.init(formState: TodoFormState(), context: context, repository: repository)
    }

    /// preview 용 편의 init
    convenience init(preview: Bool) {
        self.init(context: CoreDataManager.preview.viewContext)
    }

    // MARK: - Actions

    func save() throws {
        do {
            let todo = try repository.createTodo(
                title: formState.title.trimmingCharacters(in: .whitespacesAndNewlines),
                memo: formState.memo.isEmpty ? nil : formState.memo,
                dueDate: formState.hasDueDate ? formState.dueDate : nil,
                priority: formState.priority,
                category: formState.selectedCategory
            )
            if formState.hasDueDate {
                NotificationManager.shared.scheduleDueDateNotification(
                    for: todo.id,
                    title: todo.title,
                    dueDate: formState.dueDate
                )
            }
            WidgetDataManager.shared.updateWidgetData()
        } catch {
            showSaveError = true
            throw error
        }
    }
}
