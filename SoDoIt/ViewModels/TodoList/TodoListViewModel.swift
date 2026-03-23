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

enum TodoListError: Identifiable {
    case todoFetch
    case categoryFetch
    case filter
    case toggle
    case delete

    var id: Self { self }

    var title: String {
        switch self {
        case .todoFetch:    "할 일 로딩 실패"
        case .categoryFetch: "카테고리 로딩 실패"
        case .filter:       "필터 적용 실패"
        case .toggle:       "상태 변경 실패"
        case .delete:       "삭제 실패"
        }
    }

    var message: String {
        switch self {
        case .todoFetch:    "할 일 목록을 불러오는 중 오류가 발생했습니다."
        case .categoryFetch: "카테고리 목록을 불러오는 중 오류가 발생했습니다."
        case .filter:       "카테고리 필터를 적용하는 중 오류가 발생했습니다."
        case .toggle:       "할 일의 완료 상태를 변경하지 못했습니다."
        case .delete:       "할 일을 삭제하지 못했습니다."
        }
    }
}

@Observable
final class TodoListViewModel: NSObject, NSFetchedResultsControllerDelegate {
    private(set) var todos: [TodoItem] = []
    private(set) var categories: [Category] = []
    var filterCategory: Category?
    var activeError: TodoListError?

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
            activeError = .todoFetch
            Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TodoListViewModel").error("할 일 fetch 실패: \(error)")
        }

        do {
            try categoryFRC.performFetch()
            categories = categoryFRC.fetchedObjects ?? []
        } catch {
            activeError = .categoryFetch
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
            activeError = .toggle
            Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TodoListViewModel").error("완료 상태 변경 실패: \(error)")
        }
    }

    func delete(_ todo: TodoItem) {
        do {
            try repository.deleteTodo(todo)
        } catch {
            activeError = .delete
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
            
            activeError = .filter
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
