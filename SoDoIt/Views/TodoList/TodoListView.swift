//
//  TodoListView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/20/26.
//

import SwiftUI

private enum SheetRoute: Identifiable {
    case addTodo
    case categoryList

    var id: Int { hashValue }
}

struct TodoListView: View {
    @State private var todoListViewModel: TodoListViewModel
    @State private var activeSheet: SheetRoute?
    
    init(viewModel: TodoListViewModel = TodoListViewModel()) {
        _todoListViewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if todoListViewModel.todos.isEmpty {
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
            .sheet(item: $activeSheet) { route in
                switch route {
                case .addTodo:
                    AddTodoView()
                case .categoryList:
                    CategoryListView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .addTodo
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        activeSheet = .categoryList
                    } label: {
                        Image(systemName: "folder.fill")
                    }
                }
            }
        }
    }
    
    // MARK: - 할 일 목록
    private var todoList: some View {
        List {
            todoSection(title: "진행 중", todos: todoListViewModel.activeTodos)
            todoSection(title: "완료됨", todos: todoListViewModel.completedTodos)
        }
    }
    
    @ViewBuilder
    private func todoSection<T: RandomAccessCollection>(title: String, todos: T) -> some View where T.Element == TodoItem {
        if !todos.isEmpty {
            Section(title) {
                ForEach(todos) { todo in
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
    
    // MARK: - 스와이프 버튼
    private func toggleButton(for todo: TodoItem) -> some View {
        Button {
            withAnimation {
                todoListViewModel.toggleCompletion(todo)
            }
        } label: {
            Image(systemName: todo.isCompleted ? "arrow.uturn.backward" : "checkmark")
        }
        .tint(.green)
    }
    
    private func deleteButton(for todo: TodoItem) -> some View {
        Button(role: .destructive) {
            withAnimation {
                todoListViewModel.delete(todo)
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
