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

    func deleteCategory(_ category: Category) {
        context.delete(category)
        do { try save() } catch { print("CoreData 저장 실패: \(error)") }
    }

    // MARK: - Private
    private func save() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}
