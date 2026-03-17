//
//  EditTodoViewModel.swift
//  SoDoIt
//
//  Created by 한소희 on 3/12/26.
//

import Foundation
import CoreData
import Observation
import OSLog

@Observable
final class EditTodoViewModel: NSObject, NSFetchedResultsControllerDelegate {
    var formState: TodoFormState
    var showSaveError = false

    private(set) var categories: [Category] = []

    private let todo: TodoItem
    private let categoryFRC: NSFetchedResultsController<Category>
    private let repository: TodoRepository

    init(
        todo: TodoItem,
        context: NSManagedObjectContext = CoreDataManager.shared.viewContext,
        repository: TodoRepository? = nil
    ) {
        self.todo = todo
        self.repository = repository ?? TodoRepository(context: context)

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
        self.formState = state

        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ]
        categoryFRC = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()
        categoryFRC.delegate = self

        do {
            try categoryFRC.performFetch()
            categories = categoryFRC.fetchedObjects ?? []
        } catch {
            Logger(subsystem: Bundle.main.bundleIdentifier!, category: "EditTodoViewModel")
                .error("카테고리 fetch 실패: \(error)")
        }
    }

    // MARK: - Actions

    func save() {
        repository.updateTodo(
            todo,
            title: formState.title.trimmingCharacters(in: .whitespacesAndNewlines),
            memo: formState.memo.isEmpty ? nil : formState.memo,
            dueDate: formState.hasDueDate ? formState.dueDate : nil,
            priority: formState.priority,
            category: formState.selectedCategory
        )
    }

    // MARK: - NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        categories = controller.fetchedObjects as? [Category] ?? []
    }
}
