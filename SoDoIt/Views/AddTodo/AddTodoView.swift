//
//  AddTodoView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/22/26.
//

import SwiftUI
import OSLog

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddTodoViewModel

    init(viewModel: AddTodoViewModel = AddTodoViewModel()){
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            TodoFormBodyView(viewModel: viewModel)
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
                                try viewModel.save()
                                dismiss()
                            } catch {
                                Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AddTodoView").error("할 일 저장 실패: \(error)")
                            }
                        }
                        .disabled(!viewModel.formState.canSave)
                    }
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
            Text("카테고리 목록을 불러오지 못했습니다. 카테고리 없이 추가할 수 있습니다.")
        }
    }
}

#Preview {
    AddTodoView(viewModel: AddTodoViewModel(preview: true))
}
