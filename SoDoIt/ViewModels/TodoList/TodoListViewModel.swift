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
    case sort

    var id: Self { self }

    var title: String {
        switch self {
        case .todoFetch:    "할 일 로딩 실패"
        case .categoryFetch: "카테고리 로딩 실패"
        case .filter:       "필터 적용 실패"
        case .toggle:       "상태 변경 실패"
        case .delete:       "삭제 실패"
        case .sort:         "정렬 실패"
        }
    }

    var message: String {
        switch self {
        case .todoFetch:    "할 일 목록을 불러오는 중 오류가 발생했습니다."
        case .categoryFetch: "카테고리 목록을 불러오는 중 오류가 발생했습니다."
        case .filter:       "필터를 적용하는 중 오류가 발생했습니다."
        case .toggle:       "할 일의 완료 상태를 변경하지 못했습니다."
        case .delete:       "할 일을 삭제하지 못했습니다."
        case .sort:         "정렬을 적용하는 중 오류가 발생했습니다."
        }
    }
}

@Observable
final class TodoListViewModel: NSObject, NSFetchedResultsControllerDelegate {
    private(set) var todos: [TodoItem] = []
    private(set) var categories: [Category] = []
    var filterCategory: Category?
    var smartFilter: SmartFilter = .all
    var sortOption: SortOption = .priority
    var isSortAscending: Bool = true
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

    func applySortOption(_ option: SortOption) {
        if sortOption == option {
            isSortAscending.toggle()
        } else {
            sortOption = option
            isSortAscending = option.defaultAscending
        }
        updateSortDescriptors()
    }

    func todo(for objectID: NSManagedObjectID) -> TodoItem? {
        try? fetchedResultsController.managedObjectContext.existingObject(with: objectID) as? TodoItem
    }

    func applyFilter(_ category: Category?) {
        let newCategory = (filterCategory?.objectID == category?.objectID) ? nil : category
        applyFilters(smartFilter: smartFilter, category: newCategory)
    }

    func applySmartFilter(_ filter: SmartFilter) {
        applyFilters(smartFilter: filter, category: filterCategory)
    }

    private func applyFilters(smartFilter newSmartFilter: SmartFilter, category newCategory: Category?) {
        let oldPredicate = fetchedResultsController.fetchRequest.predicate

        var predicates: [NSPredicate] = []

        // 스마트 필터 predicate
        switch newSmartFilter {
        case .all:
            break
        case .today:
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: Date())
            guard let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { break }
            predicates.append(NSPredicate(format: "dueDate >= %@ AND dueDate < %@ AND isCompleted == NO", startOfDay as NSDate, startOfTomorrow as NSDate))
        case .upcoming:
            let calendar = Calendar.current
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) else { break }
            predicates.append(NSPredicate(format: "dueDate != nil AND dueDate >= %@ AND isCompleted == NO", tomorrow as NSDate))
        case .completed:
            predicates.append(NSPredicate(format: "isCompleted == YES"))
        }

        // 카테고리 필터 predicate
        if let category = newCategory {
            predicates.append(NSPredicate(format: "category == %@", category))
        }

        fetchedResultsController.fetchRequest.predicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        do {
            try fetchedResultsController.performFetch()
            smartFilter = newSmartFilter
            filterCategory = newCategory
            todos = fetchedResultsController.fetchedObjects ?? []
        } catch {
            fetchedResultsController.fetchRequest.predicate = oldPredicate

            activeError = .filter
            Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TodoListViewModel").error("필터 적용 실패: \(error)")
        }
    }

    private func updateSortDescriptors() {
        let oldDescriptors = fetchedResultsController.fetchRequest.sortDescriptors

        var descriptors: [NSSortDescriptor] = [
            NSSortDescriptor(keyPath: \TodoItem.isCompleted, ascending: true)
        ]

        switch sortOption {
        case .priority:
            descriptors.append(NSSortDescriptor(keyPath: \TodoItem.priority, ascending: isSortAscending))
            descriptors.append(NSSortDescriptor(keyPath: \TodoItem.createdAt, ascending: false))
        case .dueDate:
            descriptors.append(NSSortDescriptor(keyPath: \TodoItem.dueDate, ascending: isSortAscending))
            descriptors.append(NSSortDescriptor(keyPath: \TodoItem.priority, ascending: true))
        case .createdDate:
            descriptors.append(NSSortDescriptor(keyPath: \TodoItem.createdAt, ascending: isSortAscending))
        }

        fetchedResultsController.fetchRequest.sortDescriptors = descriptors

        do {
            try fetchedResultsController.performFetch()
            todos = fetchedResultsController.fetchedObjects ?? []
        } catch {
            fetchedResultsController.fetchRequest.sortDescriptors = oldDescriptors
            activeError = .sort
            Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TodoListViewModel").error("정렬 적용 실패: \(error)")
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
                    // 카테고리가 삭제된 경우 필터 해제
                    applyFilter(nil)
                } else if let updatedFilter = newCategories.first(where: { $0.objectID == currentFilter.objectID }) {
                    // 카테고리가 수정된 경우 참조 갱신
                    self.filterCategory = updatedFilter
                } else {
                    // 필터 중인 카테고리가 목록에서 사라진 경우 필터 해제
                    applyFilter(nil)
                }
            }
        }
    }
}
