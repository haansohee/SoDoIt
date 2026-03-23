//
//  TodoListViewModel.swift
//  SoDoIt
//
//  Created by 한소희 on 2/21/26.
//

import Foundation
import CoreData
import Observation
import OSLog

@Observable
final class TodoListViewModel: NSObject, NSFetchedResultsControllerDelegate {
    private(set) var todos: [TodoItem] = []
    private(set) var categories: [Category] = []
    var filterCategory: Category?
    var showTodoFetchError = false
    var showCategoryFetchError = false
    var showFilterError = false
    var showToggleError = false
    var showDeleteError = false

    private let fetchedResultsController: NSFetchedResultsController<TodoItem>
    private let categoryFRC: NSFetchedResultsController<Category>
    private let repository: TodoRepository

    private var splitIndex: Int {
        todos.firstIndex { $0.isCompleted } ?? todos.endIndex
    }
    var activeTodos: [TodoItem] {
        Array(todos.prefix(upTo: splitIndex))
    }
    var completedTodos: [TodoItem] {
        Array(todos.suffix(from: splitIndex))
    }

    init(
        context: NSManagedObjectContext = CoreDataManager.shared.viewContext,
        repository: TodoRepository? = nil
    ) {
        self.repository = repository ?? TodoRepository(context: context)

        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TodoItem.isCompleted, ascending: true),
            NSSortDescriptor(keyPath: \TodoItem.priority, ascending: true),
            NSSortDescriptor(keyPath: \TodoItem.createdAt, ascending: false)
        ]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
        categoryRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
        ]
        categoryFRC = NSFetchedResultsController(
            fetchRequest: categoryRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()
        fetchedResultsController.delegate = self
        categoryFRC.delegate = self

        do {
            try fetchedResultsController.performFetch()
            todos = fetchedResultsController.fetchedObjects ?? []
        } catch {
            showTodoFetchError = true
            Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TodoListViewModel").error("할 일 fetch 실패: \(error)")
        }

        do {
            try categoryFRC.performFetch()
            categories = categoryFRC.fetchedObjects ?? []
        } catch {
            showCategoryFetchError = true
            Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TodoListViewModel").error("카테고리 fetch 실패: \(error)")
        }
    }

    /// preview용 편의 이니셜라이저
    convenience init(preview: Bool) {
        self.init(context: CoreDataManager.preview.viewContext)
    }

    // MARK: - Actions

    func toggleCompletion(_ todo: TodoItem) {
        do {
            try repository.toggleTodoCompletion(todo)
        } catch {
            showToggleError = true
            Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TodoListViewModel").error("완료 상태 변경 실패: \(error)")
        }
    }

    func delete(_ todo: TodoItem) {
        do {
            try repository.deleteTodo(todo)
        } catch {
            showDeleteError = true
            Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TodoListViewModel").error("할 일 삭제 실패: \(error)")
        }
    }

    func todo(for objectID: NSManagedObjectID) -> TodoItem? {
        try? fetchedResultsController.managedObjectContext.existingObject(with: objectID) as? TodoItem
    }

    func applyFilter(_ category: Category?) {
        let oldFilter = self.filterCategory
        let oldPredicate = fetchedResultsController.fetchRequest.predicate
        
        let newFilter = (filterCategory?.objectID == category?.objectID) ? nil : category
        filterCategory = newFilter
        fetchedResultsController.fetchRequest.predicate = newFilter.map { NSPredicate(format: "category == %@", $0) }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // Revert state on failure
            filterCategory = oldFilter
            fetchedResultsController.fetchRequest.predicate = oldPredicate
            
            showFilterError = true
            Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TodoListViewModel").error("TodoListViewModel 필터 적용 실패: \(error)")
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller === fetchedResultsController {
            todos = controller.fetchedObjects as? [TodoItem] ?? []
        } else if controller === categoryFRC {
            let newCategories = controller.fetchedObjects as? [Category] ?? []
            self.categories = newCategories
            
            if let currentFilter = self.filterCategory {
                if currentFilter.isDeleted {
                    // Category was deleted, clear filter
                    applyFilter(nil)
                } else if let updatedFilter = newCategories.first(where: { $0.objectID == currentFilter.objectID }) {
                    // Category might have been updated, refresh the reference
                    self.filterCategory = updatedFilter
                } else {
                    // The filtered category is lo longer in the fetched list for some reason, clear filter
                    applyFilter(nil)
                }
            }
        }
    }
}
