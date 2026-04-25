//
//  TodoWidgetProvider.swift
//  SoDoItWidget
//
//  Created by 한소희 on 4/25/26.
//

import WidgetKit
import Foundation

struct TodoWidgetEntry: TimelineEntry {
    let date: Date
    let todos: [WidgetTodoItem]
    let stats: WidgetStats
}

struct TodoWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoWidgetEntry {
        TodoWidgetEntry(
            date: Date(),
            todos: [
                WidgetTodoItem(id: UUID(), title: "할 일 예시", priority: 0, dueDate: nil, categoryName: nil, categoryColorHex: nil)
            ],
            stats: WidgetStats(totalCount: 5, completedCount: 2, todayCount: 1)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoWidgetEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoWidgetEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> TodoWidgetEntry {
        let defaults = AppGroup.sharedDefaults
        let decoder = JSONDecoder()

        var todos: [WidgetTodoItem] = []
        var stats = WidgetStats(totalCount: 0, completedCount: 0, todayCount: 0)

        if let todosData = defaults?.data(forKey: AppGroup.todosKey),
           let decoded = try? decoder.decode([WidgetTodoItem].self, from: todosData) {
            todos = decoded
        }
        if let statsData = defaults?.data(forKey: AppGroup.statsKey),
           let decoded = try? decoder.decode(WidgetStats.self, from: statsData) {
            stats = decoded
        }

        return TodoWidgetEntry(date: Date(), todos: todos, stats: stats)
    }
}
