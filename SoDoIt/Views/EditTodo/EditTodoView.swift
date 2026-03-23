//
//  EditTodoView.swift
//  SoDoIt
//
//  Created by 한소희 on 3/12/26.
//

import SwiftUI
import OSLog

struct EditTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: EditField?
    @State private var viewModel: EditTodoViewModel

    private enum EditField: Hashable {
        case title, memo
    }

    init(todo: TodoItem) {
        _viewModel = State(wrappedValue: EditTodoViewModel(todo: todo))
    }

    var body: some View {
        Form {
            titleSection
            memoSection
            dueDateSection
            prioritySection
            categorySection
        }
        .onTapGesture {
            focusedField = nil
        }
        .navigationTitle("할 일 수정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") {
                    do {
                        try viewModel.save()
                        dismiss()
                    } catch {
                        Logger(subsystem: Bundle.main.bundleIdentifier!, category: "EditTodoView")
                            .error("할 일 수정 저장 실패: \(error)")
                    }
                }
                .disabled(!viewModel.formState.canSave)
            }
        }
        .alert("저장 실패", isPresented: $viewModel.showSaveError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("할 일을 저장하지 못했습니다. 다시 시도해 주세요.")
        }
        .alert("카테고리 불러오기 실패", isPresented: $viewModel.showCategoryFetchError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("카테고리 목록을 불러오지 못했습니다. 카테고리 없이 수정할 수 있습니다.")
        }
    }

    // MARK: - Title Section
    private var titleSection: some View {
        Section {
            TextField("할 일을 입력하세요", text: $viewModel.formState.title)
                .focused($focusedField, equals: .title)
        } header: {
            Text("제목")
        }
    }

    // MARK: - Memo Section
    private var memoSection: some View {
        Section {
            TextField("메모를 입력하세요", text: $viewModel.formState.memo)
                .focused($focusedField, equals: .memo)
        } header: {
            Text("메모")
        }
    }

    // MARK: - DueDate Section
    private var dueDateSection: some View {
        Section {
            Toggle("마감일 설정", isOn: $viewModel.formState.hasDueDate.animation())
            if viewModel.formState.hasDueDate {
                DatePicker(
                    "마감일",
                    selection: $viewModel.formState.dueDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
        } header: {
            Text("마감일")
        }
    }

    // MARK: - Priority Section
    private var prioritySection: some View {
        Section {
            Picker("우선순위", selection: $viewModel.formState.priority) {
                ForEach(Priority.allCases, id: \.self) { priority in
                    Text(priority.title).tag(priority)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("우선순위")
        }
    }

    // MARK: - Category Section
    private var categorySection: some View {
        Section {
            Picker("카테고리", selection: $viewModel.formState.selectedCategory) {
                Text("선택 안 함").tag(nil as Category?)
                ForEach(viewModel.categories) { category in
                    Text(category.name).tag(category as Category?)
                }
            }
        } header: {
            Text("카테고리")
        }
    }
}
