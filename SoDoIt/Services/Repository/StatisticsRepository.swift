//
//  StatisticsRepository.swift
//  SoDoIt
//
//  Created by 한소희 on 2/20/26.
//

import Foundation
import CoreData
import OSLog

final class StatisticsRepository {
    private let context: NSManagedObjectContext
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "sso.SoDoIt",
        category: "StatisticsRepository"
    )

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
        return safeCount(for: request, label: "completionCount")
    }

    /// 최근 7일간 일별 완료 개수. 단일 fetch 후 메모리에서 그룹화하여 7번의 count 쿼리를 1회로 통합.
    func weeklyCompletionDate() -> [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekStart = calendar.date(byAdding: .day, value: -6, to: today),
              let weekEnd = calendar.date(byAdding: .day, value: 1, to: today) else {
            return []
        }

        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        request.predicate = NSPredicate(
            format: "isCompleted == YES AND completedAt >= %@ AND completedAt < %@",
            weekStart as NSDate,
            weekEnd as NSDate
        )
        request.propertiesToFetch = ["completedAt"]
        request.resultType = .managedObjectResultType

        let items: [TodoItem]
        do {
            items = try context.fetch(request)
        } catch {
            logger.error("주간 완료 fetch 실패: \(error.localizedDescription, privacy: .public)")
            items = []
        }

        // 일자별로 그룹화 (key: 자정 기준 Date)
        let countsByDay = Dictionary(grouping: items) { item in
            calendar.startOfDay(for: item.completedAt ?? Date.distantPast)
        }
        .mapValues(\.count)

        // 7일치를 빠진 날짜 0으로 채워서 오래된 → 최신 순서로 반환
        return (0..<7).compactMap { offset -> (date: Date, count: Int)? in
            guard let day = calendar.date(byAdding: .day, value: offset, to: weekStart) else {
                return nil
            }
            return (date: day, count: countsByDay[day] ?? 0)
        }
    }

    /// 전체 할 일 개수
    func totalCount() -> Int {
        safeCount(for: TodoItem.fetchRequest(), label: "totalCount")
    }

    /// 완료된 전체 할 일 개수
    func completedTotalCount() -> Int {
        let request = TodoItem.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == YES")
        return safeCount(for: request, label: "completedTotalCount")
    }

    /// 진행 중(미완료) 할 일 개수
    func inProgressCount() -> Int {
        let request = TodoItem.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == NO")
        return safeCount(for: request, label: "inProgressCount")
    }

    /// 전체 완료율 (0.0 ~ 1.0). 할 일이 없으면 0.
    func completionRate() -> Double {
        let total = totalCount()
        guard total > 0 else { return 0 }
        return total > 0 ? Double(completedTotalCount()) / Double(total) : 0.0
    }

    /// 우선순위별 할 일 개수 (높음/보통/낮음 순서)
    func countByPriority() -> [(priority: Priority, count: Int)] {
        Priority.allCases.map { priority in
            let request = TodoItem.fetchRequest()
            request.predicate = NSPredicate(format: "priority == %d", priority.rawValue)
            let count = safeCount(for: request, label: "countByPriority(\(priority))")
            return (priority: priority, count: count)
        }
    }

    // MARK: - Private

    /// 통계용 fail-soft count 헬퍼. 실패 시 Logger로 기록 후 0 반환.
    private func safeCount<T: NSFetchRequestResult>(for request: NSFetchRequest<T>, label: String) -> Int {
        do {
            return try context.count(for: request)
        } catch {
            logger.error("\(label, privacy: .public) 조회 실패: \(error.localizedDescription, privacy: .public)")
            return 0
        }
    }
}
