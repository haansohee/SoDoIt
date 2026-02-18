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
    
    // MARK: - TodoItem CRUD

    @discardableResult
    func createTodo(
        title: String,
        memo: String? = nil,
        dueDate: Date? = nil,
        priority: Priority = .medium,
        category: Category? = nil
    ) -> TodoItem {
        let todo = TodoItem(context: viewContext)
        todo.title = title
        todo.memo = memo
        todo.dueDate = dueDate
        todo.priority = priority.rawValue
        todo.category = category
        save()
        return todo
    }
    
    func updateTodo(
        _ todo: TodoItem,
        title: String,
        memo: String?,
        dueDate: Date?,
        priority: Priority,
        category: Category?
    ) {
        todo.title = title
        todo.memo = memo
        todo.dueDate = dueDate
        todo.priority = priority.rawValue
        todo.category = category
        save()
    }
    
    func toggleTodoCompletion(_ todo: TodoItem) {
        todo.isCompleted.toggle()
        todo.completedAt = todo.isCompleted ? Date() : nil
        save()
    }
    
    func deleteTodo(_ todo: TodoItem) {
        viewContext.delete(todo)
        save()
    }
    
    // MARK: - Category CRUD
    
    @discardableResult
    func createCategory(
        name: String,
        colorHex: String = "#007AFF",
        iconName: String = "folder.fill"
    ) -> Category {
        let category = Category(context: viewContext)
        category.name = name
        category.colorHex = colorHex
        category.iconName = iconName
        save()
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
        save()
    }
    
    func deleteCategory(_ category: Category) {
        viewContext.delete(category)
        save()
    }
    
    // MARK: - Statistics
    
    func completionCount(for date: Date) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return 0 }
        
        let request = TodoItem.fetchRequest()
        request.predicate = NSPredicate(
            format: "isCompleted == YES AND completedAt >= %@ AND completedAt < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
            )
        
        do {
            return try viewContext.count(for: request)
        } catch {
            print("통계 조회 실패: \(error.localizedDescription)")
            return 0
        }
    }

    func weeklyCompletionDate() -> [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                return nil
            }
            return (date: date, count: completionCount(for: date))
        }.reversed()
    }
}
