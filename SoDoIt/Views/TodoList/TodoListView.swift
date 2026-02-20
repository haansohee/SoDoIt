//
//  TodoListView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/20/26.
//

import SwiftUI

struct TodoListView: View {
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \TodoItem.isCompleted, ascending: true),
            NSSortDescriptor(keyPath: \TodoItem.priority, ascending: true),
            NSSortDescriptor(keyPath: \TodoItem.createdAt, ascending: false)
        ]
    ) private var todos: FetchedResults<TodoItem>
    
    private let repository = TodoRepository()
    
    private var activeTodos: [TodoItem] {
        todos.filter { !$0.isCompleted }
    }
    
    private var completedTodos: [TodoItem] {
        todos.filter { $0.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if todos.isEmpty {
                    ContentUnavailableView(
                        "할 일이 없습니다",
                        systemImage: "checklist",
                        description: Text("+ 버튼을 눌러 새로운 할 일을 추가하세요")
                    )
                } else {
                    todoList
                }
            }
            .navigationTitle("할 일")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO: AddTodoView 연결하기
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    // MARK: - 할 일 목록
    private var todoList: some View {
        List {
            if !activeTodos.isEmpty {
                Section("진행 중") {
                    ForEach(activeTodos) { todo in
                        TodoRowView(todo: todo)
                            .swipeActions(edge: .leading) {
                                toggleButton(for: todo)
                            }
                            .swipeActions(edge: .trailing) {
                                deleteButton(for: todo)
                            }
                    }
                }
            }
            
            if !completedTodos.isEmpty {
                Section("완료됨") {
                    ForEach(completedTodos) { todo in
                        TodoRowView(todo: todo)
                            .swipeActions(edge: .leading) {
                                toggleButton(for: todo)
                            }
                            .swipeActions(edge: .trailing) {
                                deleteButton(for: todo)
                            }
                    }
                }
            }
        }
    }
    
    // MARK: - 스와이프 버튼
    private func toggleButton(for todo: TodoItem) -> some View {
        Button {
            withAnimation {
                repository.toggleTodoCompletion(todo)
            }
        } label: {
            Image(systemName: todo.isCompleted ? "arrow.uturn.backward" : "checkmark")
        }
        .tint(.green)
    }
    
    private func deleteButton(for todo: TodoItem) -> some View {
        Button(role: .destructive) {
            withAnimation {
                repository.deleteTodo(todo)
            }
        } label: {
            Image(systemName: "trash")
        }
    }
}

#Preview {
    TodoListView()
        .environment(\.managedObjectContext, CoreDataManager.preview.viewContext)
}
