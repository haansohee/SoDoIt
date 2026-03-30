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
    @State private var viewModel: EditTodoViewModel

    init(todo: TodoItem) {
        _viewModel = State(wrappedValue: EditTodoViewModel(todo: todo))
    }

    var body: some View {
        TodoFormBodyView(viewModel: viewModel)
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
}
