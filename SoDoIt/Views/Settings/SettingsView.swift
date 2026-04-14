//
//  SettingsView.swift
//  SoDoIt
//
//  Created by 한소희 on 4/7/26.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    @State private var showingResetConfirm = false

    init(viewModel: SettingsViewModel = SettingsViewModel()) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                appInfoSection
                dataSection
                supportSection
            }
            .navigationTitle("설정")
            .confirmationDialog(
                "모든 데이터를 삭제하시겠습니까?",
                isPresented: $showingResetConfirm,
                titleVisibility: .visible
            ) {
                Button("모든 데이터 삭제", role: .destructive) {
                    viewModel.resetAllData()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("할 일과 카테고리가 모두 삭제되며 복구할 수 없습니다.")
            }
            .alert(
                "오류",
                isPresented: Binding(
                    get: { viewModel.resetError != nil },
                    set: { if !$0 { viewModel.resetError = nil } }
                ),
                presenting: viewModel.resetError
            ) { _ in
                Button("확인", role: .cancel) {}
            } message: { message in
                Text(message)
            }
        }
    }

    private var appInfoSection: some View {
        Section("앱 정보") {
            LabeledContent("버전", value: viewModel.appVersion)
        }
    }

    private var dataSection: some View {
        Section {
            Button(role: .destructive) {
                showingResetConfirm = true
            } label: {
                Label("모든 데이터 삭제", systemImage: "trash")
            }
            .disabled(viewModel.isResetting)
        } header: {
            Text("데이터")
        } footer: {
            Text("할 일과 카테고리를 모두 삭제합니다. 이 작업은 되돌릴 수 없습니다.")
        }
    }

    private var supportSection: some View {
        Section("지원") {
            Link(destination: URL(string: "mailto:feedback@sodoit.app")!) {
                Label("피드백 보내기", systemImage: "envelope")
            }
        }
    }
}

#Preview {
    SettingsView()
}
