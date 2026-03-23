//
//  AddTodoViewModel.swift
//  SoDoIt
//
//  Created by 한소희 on 2/22/26.
//

import Foundation
import CoreData
import Observation
import OSLog

struct TodoFormState {
    var title: String = ""
    var memo: String = ""
    var dueDate: Date = Date()
    var hasDueDate: Bool = false
    var priority: Priority = .medium
    var selectedCategory: Category?
    
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}


@Observable
final class AddTodoViewModel: NSObject, NSFetchedResultsControllerDelegate {
    var formState = TodoFormState()
    var showSaveError = false
    var showCategoryFetchError = false

    private(set) var categories: [Category] = []
    
    private let fetchedResultsController: NSFetchedResultsController<Category>
    private let repository: TodoRepository
    
    
    
    init(
        context: NSManagedObjectContext = CoreDataManager.shared.viewContext,
        repository: TodoRepository? = nil
    ) {
        self.repository = repository ?? TodoRepository(context: context)
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Category.name, ascending: true)
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
            categories = fetchedResultsController.fetchedObjects ?? []
        } catch {
            showCategoryFetchError = true
            Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AddTodoViewModel").error("카테고리 fetch 실패: \(error)")
        }
    }
    
    /// preview 용 편의 init
    convenience init(preview: Bool) {
        self.init(context: CoreDataManager.preview.viewContext)
    }
    
    // MARK: Actions
    
    func save() throws {
        do {
            try repository.createTodo(
                title: formState.title.trimmingCharacters(in: .whitespacesAndNewlines),
                memo: formState.memo.isEmpty ? nil : formState.memo,
                dueDate: formState.hasDueDate ? formState.dueDate : nil,
                priority: formState.priority,
                category: formState.selectedCategory
            )
        } catch {
            showSaveError = true
            throw error
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        categories = controller.fetchedObjects as? [Category] ?? []
    }
}
