//
//  CategoryRepository.swift
//  SoDoIt
//
//  Created by 한소희 on 2/20/26.
//

import Foundation
import CoreData

final class CategoryRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.context = context
    }

    // MARK: - Category CRUD
    @discardableResult
    func createCategory(
        name: String,
        colorHex: String = "#007AFF",
        iconName: String = "folder.fill"
    ) throws -> Category {
        let category = Category(context: context)
        category.name = name
        category.colorHex = colorHex
        category.iconName = iconName
        do {
            try save()
        } catch {
            context.rollback()
            throw error
        }
        return category
    }

    func updateCategory(
        _ category: Category,
        name: String,
        colorHex: String,
        iconName: String
    ) throws {
        category.name = name
        category.colorHex = colorHex
        category.iconName = iconName
        do {
            try save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func deleteCategory(_ category: Category) throws {
        context.delete(category)
        do {
            try save()
        } catch {
            context.rollback()
            throw error
        }
    }

    func deleteAllCategories() throws {
        let request: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
        batchDelete.resultType = .resultTypeObjectIDs
        do {
            let result = try context.execute(batchDelete) as? NSBatchDeleteResult
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            }
        } catch {
            context.rollback()
            throw error
        }
    }

    // MARK: - Private
    private func save() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
