//
//  CoreDataManager.swift
//  SoDoIt
//
//  Created by 한소희 on 2/8/26.
//

import Foundation
import CoreData

final class CoreDataManager {

    static let shared = CoreDataManager()

    /// Preview용 인메모리 인스턴스
    static var preview: CoreDataManager = {
        let manager = CoreDataManager(inMemory: true)
        let context = manager.container.viewContext

        // 샘플 카테고리 (id, createdAt은 awakeFromInsert에서 자동 설정)
        let workCategory = Category(context: context)
        workCategory.name = "업무"
        workCategory.colorHex = "#FF3B30"
        workCategory.iconName = "briefcase.fill"

        let personalCategory = Category(context: context)
        personalCategory.name = "개인"
        personalCategory.colorHex = "#34C759"
        personalCategory.iconName = "person.fill"

        // 샘플 할 일 (id, createdAt은 awakeFromInsert에서 자동 설정)
        for i in 0..<5 {
            let todo = TodoItem(context: context)
            todo.title = "샘플 할 일 \(i + 1)"
            todo.memo = i % 2 == 0 ? "메모가 있는 할 일입니다." : nil
            todo.priority = Int16(i % 3)
            todo.isCompleted = i > 2
            todo.completedAt = i > 2 ? Date() : nil
            todo.dueDate = i < 3 ? Calendar.current.date(byAdding: .day, value: i, to: Date()) : nil
            todo.category = i % 2 == 0 ? workCategory : personalCategory
        }

        do {
            try context.save()
        } catch {
            fatalError("CoreData Preview 저장 실패: \(error)")
        }

        return manager
    }()

    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SoDoIt")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreData 로드 실패: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    // MARK: - Save

    func save() {
        let context = viewContext
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            print("CoreData 저장 실패: \(error)")
        }
    }
}
