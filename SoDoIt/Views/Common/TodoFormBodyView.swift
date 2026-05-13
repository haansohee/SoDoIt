//
//  TodoFormBodyView.swift
//  SoDoIt
//
//  Created by 한소희 on 3/23/26.
//

import SwiftUI

struct TodoFormBodyView: View {
    @Bindable var viewModel: TodoFormViewModel
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case title, memo
    }

    var body: some View {
        Form {
            titleSection
            memoSection
            dueDateSection
            prioritySection
            categorySection
        }
        .scrollDismissesKeyboard(.interactively)
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
