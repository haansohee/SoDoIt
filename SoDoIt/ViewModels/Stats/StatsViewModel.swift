//
//  StatsViewModel.swift
//  SoDoIt
//
//  Created by 한소희 on 4/7/26.
//

import Foundation
import CoreData
import Observation

@Observable
final class StatsViewModel {
    // MARK: - Summary
    private(set) var todayCompletedCount: Int = 0
    private(set) var totalCount: Int = 0
    private(set) var inProgressCount: Int = 0
    private(set) var completionRate: Double = 0

    // MARK: - Charts
    private(set) var weeklyCompletion: [(date: Date, count: Int)] = []
    private(set) var priorityDistribution: [(priority: Priority, count: Int)] = []

    // MARK: - Display

    var completionRateText: String {
        let percent = Int((completionRate * 100).rounded())
        return "\(percent)%"
    }

    private let repository: StatisticsRepository

    init(repository: StatisticsRepository? = nil) {
        self.repository = repository ?? StatisticsRepository()
        refresh()
    }

    /// preview용 편의 이니셜라이저
    convenience init(preview: Bool) {
        self.init(repository: StatisticsRepository(context: CoreDataManager.preview.viewContext))
    }

    // MARK: - Actions

    func refresh() {
        todayCompletedCount = repository.completionCount(for: Date())
        totalCount = repository.totalCount()
        inProgressCount = repository.inProgressCount()
        completionRate = totalCount > 0 ? Double(totalCount - inProgressCount) / Double(totalCount) : 0
        weeklyCompletion = repository.weeklyCompletionDate()
        priorityDistribution = repository.countByPriority()
    }
}
