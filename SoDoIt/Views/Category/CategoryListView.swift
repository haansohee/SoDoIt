//
//  CategoryListView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/26/26.
//

import SwiftUI

struct CategoryListView: View {
    @State private var categoryListViewModel: CategoryListViewModel
    @State private var showingAddCategory = false
    
    init(viewModel: CategoryListViewModel = CategoryListViewModel()) {
        _categoryListViewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if categoryListViewModel.categories.isEmpty {
                    EmptyStateView(
                        title: "카테고리가 없습니다",
                        systemImage: "folder",
                        description: "할 일을 분류할 카테고리를 추가해 보세요",
                        actionTitle: "카테고리 추가",
                        action: { showingAddCategory = true }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                } else {
                    categoryList
                        .transition(.opacity)
                }
            }
            .animation(AppAnimation.listTransition, value: categoryListViewModel.categories.isEmpty)
            .navigationTitle("카테고리")
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("오류", isPresented: $categoryListViewModel.showError) {
                Button("확인", role: .cancel) { }
            } message: {
                Text("작업을 처리하지 못 했습니다. 다시 시도해 주세요.")
            }
        }
    }
    
    // MARK: - 카테고리 목록
    private var categoryList: some View {
        List {
            // id: \.objectID — Identifiable의 @NSManaged id(UUID)는 삭제된
            // 객체에서 KVC가 nil을 반환하며 ForEach diffing 시점에 크래시.
            // objectID는 삭제 후에도 안전 접근 가능.
            ForEach(categoryListViewModel.categories, id: \.objectID) { category in
                CategoryRowView(category: category) { name, colorHex, iconName in
                    categoryListViewModel.updateCategory(
                        category,
                        name: name,
                        colorHex: colorHex,
                        iconName: iconName
                        )
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        withAnimation {
                            categoryListViewModel.deleteCategory(category)
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
    }
}

#Preview {
    CategoryListView(viewModel: CategoryListViewModel(preview: true))
        .environment(\.managedObjectContext, CoreDataManager.preview.viewContext)
}
