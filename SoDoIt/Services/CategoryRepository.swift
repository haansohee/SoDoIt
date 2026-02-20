//
//  CategoryRepository.swift
//  SoDoIt
//
//  Created by 한소희 on 2/20/26.
//

import Foundation
import CoreData

final class CategoryRepository {
    // MARK: - Category CRUD
    @discardableResult
    func createCategory(
        name: String,
        colorHex: String = "#007AFF",
        iconName: String = "folder.fill"
    ) -> Category {
        let category = Category(context: CoreDataManager.shared.viewContext)
        category.name = name
        category.colorHex = colorHex
        category.iconName = iconName
        CoreDataManager.shared.save()
        return category
    }
    
    func updateCategory(
        _ category: Category,
        name: String,
        colorHex: String,
        iconName: String
    ) {
        category.name = name
        category.colorHex = colorHex
        category.iconName = iconName
        CoreDataManager.shared.save()
    }
    
    func deleteCategory(_ category: Category) {
        CoreDataManager.shared.viewContext.delete(category)
        CoreDataManager.shared.save()
    }

}
