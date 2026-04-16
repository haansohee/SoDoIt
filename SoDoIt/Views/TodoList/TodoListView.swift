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
                        withAnimation(.easeInOut(duration: 0.25)) {
                            todoListViewModel.applySmartFilter(filter)
                        }
                    }
                )

                if !todoListViewModel.categories.isEmpty {
                    CategoryFilterBar(
                        categories: todoListViewModel.categories,
                        selectedCategory: todoListViewModel.filterCategory,
                        onSelect: { category in
                            withAnimation(.easeInOut(duration: 0.25)) {
                                todoListViewModel.applyFilter(category)
                            }
                        }
                    )
                }

                Group {
                    if todoListViewModel.todos.isEmpty {
                        let showAddAction = todoListViewModel.smartFilter == .all
                        EmptyStateView(
                            title: emptyMessage,
                            systemImage: "checklist",
                            description: showAddAction ? nil : "다른 필터를 선택해 보세요",
                            actionTitle: showAddAction ? "할 일 추가" : nil,
                            action: showAddAction ? { activeSheet = .addTodo } : nil
                        )
                        .frame(maxHeight: .infinity)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    } else if todoListViewModel.smartFilter == .completed {
                        completedList
                            .transition(.opacity)
                    } else {
                        todoList
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: todoListViewModel.todos.isEmpty)
                .animation(.easeInOut(duration: 0.25), value: todoListViewModel.smartFilter)
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
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                todoListViewModel.applySortOption(option)
                            } label: {
                                Label(option.label, systemImage: sortMenuIcon(for: option))
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .accessibilityLabel("정렬 옵션")
                    }
                }
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
        let categoryName = todoListViewModel.filterCategory?.name

        switch (todoListViewModel.smartFilter, categoryName) {
        case (.all, let name?):        return "\(name)에 할 일이 없습니다"
        case (.today, let name?):      return "\(name)에 오늘 마감인 할 일이 없습니다"
        case (.upcoming, let name?):   return "\(name)에 예정된 할 일이 없습니다"
        case (.completed, let name?):  return "\(name)에 완료된 할 일이 없습니다"
        case (.all, nil):              return "할 일이 없습니다"
        case (.today, nil):            return "오늘 마감인 할 일이 없습니다"
        case (.upcoming, nil):         return "예정된 할 일이 없습니다"
        case (.completed, nil):        return "완료된 할 일이 없습니다"
        }
    }

    // MARK: - 완료 필터 목록 (섹션 분리 없음)
    private var completedList: some View {
        List {
            todoRows(todoListViewModel.todos)
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
                todoRows(todos)
            }
        }
    }

    private func todoRows<T: RandomAccessCollection>(_ todos: T) -> some View where T.Element == TodoItem {
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

    // MARK: - 정렬 메뉴 아이콘
    private func sortMenuIcon(for option: SortOption) -> String {
        guard todoListViewModel.sortOption == option else {
            return option.icon
        }
        return todoListViewModel.isSortAscending ? "chevron.up" : "chevron.down"
    }
}

#Preview {
    TodoListView()
        .environment(\.managedObjectContext, CoreDataManager.preview.viewContext)
}
