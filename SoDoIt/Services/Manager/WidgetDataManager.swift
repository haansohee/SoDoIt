//
//  WidgetDataManager.swift
//  SoDoIt
//
//  Created by 한소희 on 4/25/26.
//

import Foundation
import CoreData
import WidgetKit
import OSLog

/// 메인 앱의 할 일 데이터를 위젯과 공유하는 매니저
final class WidgetDataManager {
    static let shared = WidgetDataManager()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "sso.SoDoIt", category: "Widget")

    private init() {}

    /// 위젯에 표시할 데이터를 App Group UserDefaults에 저장하고 위젯 타임라인을 갱신합니다.
    func updateWidgetData(context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        let todos = fetchTodayTodos(context: context)
        let stats = fetchStats(context: context)

        guard let defaults = AppGroup.sharedDefaults else {
            logger.warning("App Group UserDefaults를 찾을 수 없습니다.")
            return
        }

        let encoder = JSONEncoder()
        do {
            let todosData = try encoder.encode(todos)
            defaults.set(todosData, forKey: AppGroup.todosKey)
            let statsData = try encoder.encode(stats)
            defaults.set(statsData, forKey: AppGroup.statsKey)
        } catch {
            logger.error("위젯 데이터 인코딩 실패: \(error.localizedDescription)")
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    /// 위젯 데이터를 모두 제거합니다 (데이터 초기화 시 사용).
    func clearWidgetData() {
        AppGroup.sharedDefaults?.removeObject(forKey: AppGroup.todosKey)
        AppGroup.sharedDefaults?.removeObject(forKey: AppGroup.statsKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Private

    private func fetchTodayTodos(context: NSManagedObjectContext) -> [WidgetTodoItem] {
        let request = TodoItem.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == NO")
        request.sortDescriptors = [
            NSSortDescriptor(key: "priority", ascending: true),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        request.fetchLimit = 5

        do {
            let todos = try context.fetch(request)
            return todos.map { todo in
                WidgetTodoItem(
                    id: todo.id,
                    title: todo.title,
                    priority: todo.priority,
                    dueDate: todo.dueDate,
                    categoryName: todo.category?.name,
                    categoryColorHex: todo.category?.colorHex
                )
            }
        } catch {
            logger.error("위젯용 할 일 조회 실패: \(error.localizedDescription)")
            return []
        }
    }

    private func fetchStats(context: NSManagedObjectContext) -> WidgetStats {
        let allRequest = TodoItem.fetchRequest()
        let completedRequest = TodoItem.fetchRequest()
        completedRequest.predicate = NSPredicate(format: "isCompleted == YES")

        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart) ?? todayStart.addingTimeInterval(86400)
        let todayRequest = TodoItem.fetchRequest()
        todayRequest.predicate = NSPredicate(
            format: "isCompleted == YES AND completedAt >= %@ AND completedAt < %@",
            todayStart as NSDate, todayEnd as NSDate
        )

        do {
            let total = try context.count(for: allRequest)
            let completed = try context.count(for: completedRequest)
            let today = try context.count(for: todayRequest)
            return WidgetStats(totalCount: total, completedCount: completed, todayCount: today)
        } catch {
            return WidgetStats(totalCount: 0, completedCount: 0, todayCount: 0)
        }
    }
}
