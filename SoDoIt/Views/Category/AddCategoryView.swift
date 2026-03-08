//
//  AddCategoryView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/26/26.
//

import SwiftUI
import OSLog

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var addCategoryViewModel: AddCategoryViewModel
    
    init(viewModel: AddCategoryViewModel = AddCategoryViewModel()) {
        _addCategoryViewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                nameSection
                colorSection
                iconSection
                previewSection
            }
            .navigationTitle("카테고리 추가")
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
                                try addCategoryViewModel.save()
                                dismiss()
                            } catch {
                                Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AddCategoryView")
                                    .error("카테고리 저장 실패: \(error)")
                            }
                        }
                        .disabled(!addCategoryViewModel.formState.canSave)
                    }
                }
        }
        .alert("저장 실패", isPresented: $addCategoryViewModel.showSaveError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("카테고리를 저장하지 못 했습니다. 다시 시도해 주세요.")
        }
    }
    
    // MARK: - 이름 Section
    private var nameSection: some View {
        Section {
            TextField("카테고리 이름", text: $addCategoryViewModel.formState.name)
        } header: {
            Text("이름")
        }
    }
    
    // MARK: - 색상 Section
    private var colorSection: some View {
        Section {
            ColorPaletteView(selectedHex: $addCategoryViewModel.formState.colorHex)
        } header: {
            Text("색상")
        }
    }
    
    // MARK: - 아이콘 Section
    private var iconSection: some View {
        Section {
            IconPickerView(selectedIcon: $addCategoryViewModel.formState.iconName)
        } header: {
            Text("아이콘")
        }
    }
    
    // MARK: - 미리보기 Section
    private var previewSection: some View {
        Section {
            HStack(spacing: 8) {
                Image(systemName: addCategoryViewModel.formState.iconName)
                    .foregroundStyle(Color(hex: addCategoryViewModel.formState.colorHex) ?? .gray)
                Text(addCategoryViewModel.formState.name.isEmpty ? "카테고리 이름" : addCategoryViewModel.formState.name)
                    .foregroundStyle(addCategoryViewModel.formState.name.isEmpty ? .secondary : .primary)
            }
        } header: {
            Text("미리보기")
        }
    }
}

#Preview {
    AddCategoryView(viewModel: AddCategoryViewModel(preview: true))
}
