//
//  CategoryListViewModel.swift
//  SoDoIt
//
//  Created by 한소희 on 2/23/26.
//

import Foundation
import CoreData
import Observation

@Observable
final class CategoryListViewModel: NSObject, NSFetchedResultsControllerDelegate {
    private(set) var categories: [Category] = []

    private let fetchedResultsController: NSFetchedResultsController<Category>
    private let repository: CategoryRepository

    init(
        context: NSManagedObjectContext = CoreDataManager.shared.viewContext,
        repository: CategoryRepository? = nil
    ) {
        self.repository = repository ?? CategoryRepository(context: context)
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
            NSLog("CategoryListViewModel fetch 실패: \(error)")
        }
    }

    /// preview용 편의 이니셜라이저
    convenience init(preview: Bool) {
        self.init(context: CoreDataManager.preview.viewContext)
    }

    // MARK: - Actions

    func deleteCategory(_ category: Category) {
        repository.deleteCategory(category)
    }

    func updateCategory(
        _ category: Category,
        name: String,
        colorHex: String,
        iconName: String
    ) {
        repository.updateCategory(category, name: name, colorHex: colorHex, iconName: iconName)
    }

    // MARK: - NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        categories = controller.fetchedObjects as? [Category] ?? []
    }
}
