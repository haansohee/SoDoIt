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
                    ContentUnavailableView(
                        "카테고리가 없습니다",
                        systemImage: "folder",
                        description: Text("+ 버튼을 눌러 새로운 카테고리를 추가하세요")
                    )
                } else {
                    categoryList
                }
            }
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
            ForEach(categoryListViewModel.categories) { category in
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
