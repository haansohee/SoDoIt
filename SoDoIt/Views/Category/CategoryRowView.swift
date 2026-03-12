//
//  CategoryRowView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/26/26.
//

import SwiftUI
import CoreData

struct CategoryRowView: View {
    @ObservedObject var category: Category
    var onUpdate: (String, String, String) -> Void
    
    @State private var isEditing = false
    @State private var editName: String = ""
    @State private var editColorHex: String = ""
    @State private var editIconName: String = ""

    private var trimmedEditName: String {
        editName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        if isEditing {
            editingView
        } else {
            displayView
        }
    }
    
    // MARK: - 기본 표시 모드
    private var displayView: some View {
        Button {
            editName = category.name
            editColorHex = category.colorHex
            editIconName = category.iconName
            isEditing = true 
        } label: {
            HStack(spacing: 10) {
                Image(systemName: category.iconName)
                    .foregroundStyle(Color(hex: category.colorHex) ?? .gray)
                    .font(.title3)
                    .frame(width: 28)
                
                Text(category.name)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(category.activeTodoCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - 인라인 편집 모드
    private var editingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("카테고리 이름", text: $editName)
                .textFieldStyle(.roundedBorder)
            
            ColorPaletteView(selectedHex: $editColorHex)
            
            IconPickerView(selectedIcon: $editIconName)
            
            HStack {
                Button("취소") {
                    isEditing = false
                }
                .foregroundStyle(.secondary)
                
                Spacer()
                
                Button("완료") {
                    onUpdate(trimmedEditName, editColorHex, editIconName)
                    isEditing = false
                }
                .disabled(trimmedEditName.isEmpty)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let context = CoreDataManager.preview.viewContext
    let request = Category.fetchRequest()
    let categories: [Category]
    
    do {
        categories = try context.fetch(request)
    } catch {
        fatalError("미리보기 데이터 로드 실패: \(error)")
    }
    
    return List {
        if let first = categories.first {
            CategoryRowView(category: first) { _, _, _ in }
        }
    }
    .environment(\.managedObjectContext, context)

}
