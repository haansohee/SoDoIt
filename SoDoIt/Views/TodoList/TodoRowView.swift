//
//  TodoRowView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/20/26.
//

import SwiftUI
import CoreData

struct TodoRowView: View {
    @ObservedObject var todo: TodoItem
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            // 우선순위 인디케이터
            Circle()
                .fill(todo.priorityLevel.color)
                .frame(width: 10, height: 10)

            // 제목 + 뱃지
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .strikethrough(todo.isCompleted)
                    .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                    .animation(reduceMotion ? nil : AppAnimation.rowStateChange, value: todo.isCompleted)

                HStack(spacing: 6) {
                    if let dueDate = todo.dueDate {
                        dueDateBadge(dueDate)
                    }
                    if let category = todo.category {
                        categoryBadge(category)
                    }
                }
            }

            Spacer()

            // 체크마크
            checkmark
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var checkmark: some View {
        let image = Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(todo.isCompleted ? .green : .gray)
            .imageScale(.large)
            .contentTransition(.symbolEffect(.replace))

        if reduceMotion {
            image
        } else {
            image
                .symbolEffect(.bounce, value: todo.isCompleted)
                .animation(AppAnimation.rowStateChange, value: todo.isCompleted)
        }
    }
    
    // MARK: - 마감일 뱃지
    private func dueDateBadge(_ date: Date) -> some View {
        let color: Color = if todo.isOverdue {
            .red
        } else if todo.isDueToday {
            .orange
        } else {
            .gray
        }
        
        return Label(date.formatted(.dateTime.month().day()), systemImage: "calendar")
            .font(.caption)
            .foregroundStyle(color)
    }
    
    // MARK: - 카테고리 뱃지
    private func categoryBadge(_ category: Category) -> some View {
        let badgeColor = Color(hex: category.colorHex) ?? .gray
        
        return Label(category.name, systemImage: category.iconName)
            .font(.caption)
            .foregroundStyle(badgeColor)
    }
}

#Preview {
    let context = CoreDataManager.preview.viewContext
    let request = TodoItem.fetchRequest()
    let items: [TodoItem]
    
    do{
        items = try context.fetch(request)
    } catch {
        items = []
    }
    
    return List {
        ForEach(items) { item in
            TodoRowView(todo: item)
        }
    }
    .environment(\.managedObjectContext, context)
}
