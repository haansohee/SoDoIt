//
//  TodoListViewModel.swift
//  SoDoIt
//
//  Created by 한소희 on 2/21/26.
//

import Foundation
import CoreData

@Observable
final class TodoListViewModel: NSObject, NSFetchedResultsControllerDelegate {
    private(set) var todos: [TodoItem] = []
    
    private let fetchedResultsController: NSFetchedResultsController<TodoItem>
    private let repository: TodoRepository
    
    var activeTodos: [TodoItem] {
        let splitIndex = todos.firstIndex { $0.isCompleted } ?? todos.endIndex
        return Array(todos.prefix(upTo: splitIndex))
    }
    var completedTodos: [TodoItem] {
        let splitIndex = todos.firstIndex { $0.isCompleted } ?? todos.endIndex
        return Array(todos.suffix(from: splitIndex))
    }
    
    init(
        context: NSManagedObjectContext = CoreDataManager.shared.viewContext,
        repository: TodoRepository = TodoRepository()
    ) {
        self.repository = repository
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
        super.init()
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            todos = fetchedResultsController.fetchedObjects ?? []
        } catch {
            print("TodoListViewModel fetch 실패: \(error)")
        }
    }
    
    /// preview용 편의 이니셜라이저
    convenience init(preview: Bool) {
        self.init(context: CoreDataManager.shared.viewContext)
    }
    
    // MARK: - Actions
    
    func toggleCompletion(_ todo: TodoItem) {
        repository.toggleTodoCompletion(todo)
    }
    
    func delete(_ todo: TodoItem) {
        repository.deleteTodo(todo)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        todos = fetchedResultsController.fetchedObjects ?? []
    }
}
