//
//  AddTodoView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/22/26.
//

import SwiftUI
import OSLog

private enum Field: Hashable {
    case title, memo
}

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @State private var addTodoViewModel: AddTodoViewModel
    
    init(viewModel: AddTodoViewModel = AddTodoViewModel()){
        _addTodoViewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        do {
                            try addTodoViewModel.save()
                            dismiss()
                        } catch {
                            Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AddTodoView").error("할 일 저장 실패: \(error)")
                        }
                    }
                    .disabled(!addTodoViewModel.formState.canSave)
                }
            }
        }
        .alert("저장 실패", isPresented: $addTodoViewModel.showSaveError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("할 일을 저장하지 못했습니다. 다시 시도해 주세요.")
        }
        .alert("카테고리 불러오기 실패", isPresented: $addTodoViewModel.showCategoryFetchError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("카테고리 목록을 불러오지 못했습니다. 카테고리 없이 추가할 수 있습니다.")
        }
    }

    // MARK: - Title Section
    private var titleSection: some View {
        Section {
            TextField("할 일을 입력하세요", text: $addTodoViewModel.formState.title)
                .focused($focusedField, equals: .title)
        } header: {
            Text("제목")
        }
    }
    
    // MARK: - Memo Section
    private var memoSection: some View {
        Section {
            TextField("메모를 입력하세요", text: $addTodoViewModel.formState.memo)
                .focused($focusedField, equals: .memo)
        } header: {
            Text("메모")
        }
    }
    
    // MARK: - DueDate Section
    private var dueDateSection: some View {
        Section {
            Toggle("마감일 설정", isOn: $addTodoViewModel.formState.hasDueDate.animation())
            if addTodoViewModel.formState.hasDueDate {
                DatePicker(
                    "마감일",
                    selection: $addTodoViewModel.formState.dueDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
        } header: {
            Text("마감일")
        }
    }
    
    // MARK:  Priority Section
    private var prioritySection: some View {
        Section {
            Picker("우선순위", selection: $addTodoViewModel.formState.priority) {
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
            Picker("카테고리", selection: $addTodoViewModel.formState.selectedCategory) {
                Text("선택 안 함").tag(nil as Category?)
                ForEach(addTodoViewModel.categories) { category in
                    Text(category.name).tag(category as Category?)
                }
            }
        } header: {
            Text("카테고리")
        }
    }
}

#Preview {
    AddTodoView(viewModel: AddTodoViewModel(preview: true))
}
