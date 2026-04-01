//
//  TodoListView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/20/26.
//

import SwiftUI
import CoreData

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
            VStack(spacing: 0) {
                SmartFilterBar(
                    selectedFilter: todoListViewModel.smartFilter,
                    onSelect: { filter in
                        todoListViewModel.applySmartFilter(filter)
                    }
                )

                if !todoListViewModel.categories.isEmpty {
                    CategoryFilterBar(
                        categories: todoListViewModel.categories,
                        selectedCategory: todoListViewModel.filterCategory,
                        onSelect: { category in
                            todoListViewModel.applyFilter(category)
                        }
                    )
                }

                if todoListViewModel.todos.isEmpty {
                    ContentUnavailableView(
                        emptyMessage,
                        systemImage: "checklist",
                        description: Text("+ 버튼을 눌러 새로운 할 일을 추가하세요")
                    )
                    .frame(maxHeight: .infinity)
                } else if todoListViewModel.smartFilter == .completed {
                    completedList
                } else {
                    todoList
                }
            }
            .navigationDestination(for: NSManagedObjectID.self) { objectID in
                if let todo = todoListViewModel.todo(for: objectID) {
                    EditTodoView(todo: todo)
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
            .alert(
                todoListViewModel.activeError?.title ?? "",
                isPresented: Binding(
                    get: { todoListViewModel.activeError != nil },
                    set: { if !$0 { todoListViewModel.activeError = nil } }
                ),
                presenting: todoListViewModel.activeError
            ) { _ in
                Button("확인", role: .cancel) {}
            } message: { error in
                Text(error.message)
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
    
    // MARK: - 빈 상태 메시지
    private var emptyMessage: String {
        if todoListViewModel.filterCategory != nil {
            return "해당 카테고리에 할 일이 없습니다"
        }
        switch todoListViewModel.smartFilter {
        case .all:       return "할 일이 없습니다"
        case .today:     return "오늘 마감인 할 일이 없습니다"
        case .upcoming:  return "예정된 할 일이 없습니다"
        case .completed: return "완료된 할 일이 없습니다"
        }
    }

    // MARK: - 완료 필터 목록 (섹션 분리 없음)
    private var completedList: some View {
        List {
            ForEach(todoListViewModel.todos) { todo in
                NavigationLink(value: todo.objectID) {
                    TodoRowView(todo: todo)
                }
                .swipeActions(edge: .leading) {
                    toggleButton(for: todo)
                }
                .swipeActions(edge: .trailing) {
                    deleteButton(for: todo)
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
                    NavigationLink(value: todo.objectID) {
                        TodoRowView(todo: todo)
                    }
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
