//
//  AddCategoryViewModel.swift
//  SoDoIt
//
//  Created by 한소희 on 2/23/26.
//

import Foundation
import CoreData
import Observation

struct CategoryFormState {
    var name: String = ""
    var colorHex: String = "#007AFF"
    var iconName: String = "folder.fill"

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

@Observable
final class AddCategoryViewModel {
    var formState = CategoryFormState()
    var showSaveError = false

    private let repository: CategoryRepository

    init(
        context: NSManagedObjectContext = CoreDataManager.shared.viewContext,
        repository: CategoryRepository? = nil
    ) {
        self.repository = repository ?? CategoryRepository(context: context)
    }

    /// preview용 편의 이니셜라이저
    convenience init(preview: Bool) {
        self.init(context: CoreDataManager.preview.viewContext)
    }

    // MARK: - Actions

    func save() throws {
        do {
            try repository.createCategory(
                name: formState.name.trimmingCharacters(in: .whitespacesAndNewlines),
                colorHex: formState.colorHex,
                iconName: formState.iconName
            )
        } catch {
            showSaveError = true
            throw error
        }
    }
}
