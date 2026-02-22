//
//  AddTodoView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/22/26.
//

import SwiftUI

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
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
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil,
                                                from: nil,
                                                for: nil)
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
                        addTodoViewModel.save()
                        dismiss()
                    }
                    .disabled(!addTodoViewModel.formState.canSave)
                }
            }
        }
    }
    
    // MARK: - Title Section
    private var titleSection: some View {
        Section {
            TextField("할 일을 입력하세요", text: $addTodoViewModel.formState.title)
        } header: {
            Text("제목")
        }
    }
    
    // MARK: - Memo Section
    private var memoSection: some View {
        Section {
            TextField("메모를 입력하세요", text: $addTodoViewModel.formState.memo)
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
