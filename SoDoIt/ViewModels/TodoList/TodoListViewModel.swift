//
//  TodoListViewModel.swift
//  SoDoIt
//
//  Created by 한소희 on 2/21/26.
//

import Foundation
import CoreData
import Observation

@Observable
final class TodoListViewModel: NSObject, NSFetchedResultsControllerDelegate {
    private(set) var todos: [TodoItem] = []
    private(set) var categories: [Category] = []
    var filterCategory: Category?

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
            try categoryFRC.performFetch()
            categories = categoryFRC.fetchedObjects ?? []
        } catch {
            NSLog("TodoListViewModel fetch 실패: \(error)")
            print("TodoListViewModel fetch 실패: \(error)")
        }
    }

    /// preview용 편의 이니셜라이저
    convenience init(preview: Bool) {
        self.init(context: CoreDataManager.preview.viewContext)
    }

    // MARK: - Actions

    func toggleCompletion(_ todo: TodoItem) {
        repository.toggleTodoCompletion(todo)
    }

    func delete(_ todo: TodoItem) {
        repository.deleteTodo(todo)
    }

    func applyFilter(_ category: Category?) {
        if filterCategory?.objectID == category?.objectID {
            filterCategory = nil
        } else {
            filterCategory = category
        }
        
        if let currentFilter = filterCategory {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "category == %@", currentFilter)
        } else {
            fetchedResultsController.fetchRequest.predicate = nil
        }

        do {
            try fetchedResultsController.performFetch()
            todos = fetchedResultsController.fetchedObjects ?? []
        } catch {
            NSLog("TodoListViewModel 필터 적용 실패: \(error)")
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller === fetchedResultsController {
            todos = controller.fetchedObjects as? [TodoItem] ?? []
        } else if controller === categoryFRC {
            categories = controller.fetchedObjects as? [Category] ?? []
            // 필터 중인 카테고리가 삭제된 경우 필터 해제
            if let filterCategory,
               filterCategory.isDeleted {
                applyFilter(nil)
            }
        }
    }
}
