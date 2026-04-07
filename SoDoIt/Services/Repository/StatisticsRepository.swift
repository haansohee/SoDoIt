//
//  StatisticsRepository.swift
//  SoDoIt
//
//  Created by 한소희 on 2/20/26.
//

import Foundation
import CoreData

final class StatisticsRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataManager.shared.viewContext) {
        self.context = context
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
            return try context.count(for: request)
        } catch {
            print("통계 조회 실패: \(error)")
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

    /// 전체 할 일 개수
    func totalCount() -> Int {
        let request = TodoItem.fetchRequest()
        return (try? context.count(for: request)) ?? 0
    }

    /// 완료된 전체 할 일 개수
    func completedTotalCount() -> Int {
        let request = TodoItem.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == YES")
        return (try? context.count(for: request)) ?? 0
    }

    /// 진행 중(미완료) 할 일 개수
    func inProgressCount() -> Int {
        let request = TodoItem.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == NO")
        return (try? context.count(for: request)) ?? 0
    }

    /// 전체 완료율 (0.0 ~ 1.0). 할 일이 없으면 0.
    func completionRate() -> Double {
        let total = totalCount()
        guard total > 0 else { return 0 }
        return Double(completedTotalCount()) / Double(total)
    }

    /// 우선순위별 할 일 개수 (높음/보통/낮음 순서)
    func countByPriority() -> [(priority: Priority, count: Int)] {
        Priority.allCases.map { priority in
            let request = TodoItem.fetchRequest()
            request.predicate = NSPredicate(format: "priority == %d", priority.rawValue)
            let count = (try? context.count(for: request)) ?? 0
            return (priority: priority, count: count)
        }
    }
}
