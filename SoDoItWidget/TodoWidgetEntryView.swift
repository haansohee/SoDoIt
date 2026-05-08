//
//  TodoWidgetEntryView.swift
//  SoDoItWidget
//
//  Created by 한소희 on 4/25/26.
//

import SwiftUI
import WidgetKit

struct TodoWidgetEntryView: View {
    let entry: TodoWidgetEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            smallWidget
        }
    }

    // MARK: - Small Widget

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundStyle(Color.accentColor)
                Text("할 일")
                    .font(.pretendard(.headline, weight: .semibold))
                Spacer()
                Text("\(entry.stats.completedCount)/\(entry.stats.totalCount)")
                    .font(.pretendard(.caption))
                    .foregroundStyle(.secondary)
            }

            if entry.todos.isEmpty {
                Spacer()
                Text(entry.stats.totalCount > 0 ? "모든 할 일을 완료했습니다!" : "진행 중인 할 일이 없습니다")
                    .font(.pretendard(.caption))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ForEach(entry.todos.prefix(3)) { todo in
                    todoRow(todo)
                }
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - Medium Widget

    private var mediumWidget: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "checklist")
                    .foregroundStyle(Color.accentColor)
                Text("오늘의 할 일")
                    .font(.pretendard(.headline, weight: .semibold))
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("오늘 완료 \(entry.stats.todayCount)개")
                        .font(.pretendard(.caption2))
                        .foregroundStyle(.secondary)
                    Text("\(entry.stats.completedCount)/\(entry.stats.totalCount)")
                        .font(.pretendard(.caption))
                        .foregroundStyle(.secondary)
                }
            }

            if entry.todos.isEmpty {
                Spacer()
                Text(entry.stats.totalCount > 0 ? "모든 할 일을 완료했습니다!" : "진행 중인 할 일이 없습니다")
                    .font(.pretendard(.subheadline))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ForEach(entry.todos.prefix(5)) { todo in
                    todoRow(todo)
                }
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: - Components

    private func todoRow(_ todo: WidgetTodoItem) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(priorityColor(todo.priority))
                .frame(width: 6, height: 6)
            Text(todo.title)
                .font(.pretendard(.caption))
                .lineLimit(1)
            Spacer(minLength: 4)
            if let dueDate = todo.dueDate {
                Text(dueDate, format: .dateTime.hour().minute())
                    .font(.pretendard(.caption2))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func priorityColor(_ priority: Int16) -> Color {
        switch priority {
        case 0: return .red
        case 1: return .orange
        default: return .blue
        }
    }
}

#Preview("Small", as: .systemSmall) {
    TodoListWidget()
} timeline: {
    TodoWidgetEntry(
        date: Date(),
        todos: [
            WidgetTodoItem(id: UUID(), title: "회의 준비", priority: 0, dueDate: Date(), categoryName: nil, categoryColorHex: nil),
            WidgetTodoItem(id: UUID(), title: "장보기", priority: 1, dueDate: nil, categoryName: nil, categoryColorHex: nil),
            WidgetTodoItem(id: UUID(), title: "운동", priority: 2, dueDate: nil, categoryName: nil, categoryColorHex: nil)
        ],
        stats: WidgetStats(totalCount: 8, completedCount: 5, todayCount: 2)
    )
}

#Preview("Medium", as: .systemMedium) {
    TodoListWidget()
} timeline: {
    TodoWidgetEntry(
        date: Date(),
        todos: [
            WidgetTodoItem(id: UUID(), title: "회의 준비", priority: 0, dueDate: Date(), categoryName: "업무", categoryColorHex: "#FF3B30"),
            WidgetTodoItem(id: UUID(), title: "장보기", priority: 1, dueDate: nil, categoryName: nil, categoryColorHex: nil),
            WidgetTodoItem(id: UUID(), title: "운동", priority: 2, dueDate: nil, categoryName: nil, categoryColorHex: nil),
            WidgetTodoItem(id: UUID(), title: "독서 30분", priority: 2, dueDate: nil, categoryName: nil, categoryColorHex: nil)
        ],
        stats: WidgetStats(totalCount: 10, completedCount: 6, todayCount: 3)
    )
}
