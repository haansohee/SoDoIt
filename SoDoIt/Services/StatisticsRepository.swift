//
//  StatisticsRepository.swift
//  SoDoIt
//
//  Created by 한소희 on 2/20/26.
//

import Foundation
import CoreData

final class StatisticsRepository {
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
            return try CoreDataManager.shared.viewContext.count(for: request)
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
}
