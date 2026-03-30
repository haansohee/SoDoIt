//
//  TodoFormViewModel.swift
//  SoDoIt
//
//  Created by 한소희 on 3/23/26.
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
class TodoFormViewModel: NSObject, NSFetchedResultsControllerDelegate {
    var formState: TodoFormState
    var showSaveError = false
    var showCategoryFetchError = false

    private(set) var categories: [Category] = []

    let repository: TodoRepository
    private let categoryFRC: NSFetchedResultsController<Category>

    init(
        formState: TodoFormState,
        context: NSManagedObjectContext,
        repository: TodoRepository? = nil
    ) {
        self.formState = formState
        self.repository = repository ?? TodoRepository(context: context)

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
            showCategoryFetchError = true
            Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: type(of: self)))
                .error("카테고리 fetch 실패: \(error)")
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        categories = controller.fetchedObjects as? [Category] ?? []
    }
}
