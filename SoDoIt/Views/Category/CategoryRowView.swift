//
//  CategoryRowView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/26/26.
//

import SwiftUI
import CoreData

struct CategoryRowView: View {
    // 편집 시 갱신을 위해 @ObservedObject로 KVO를 구독한다.
    // 일반 let 프로퍼티만 두면 부모 리렌더 시에도 동일 참조라 body 재평가를
    // 건너뛰어 편집 결과가 반영되지 않음.
    // 삭제 시 race로 인한 크래시는 (1) body 진입의 isDeleted 가드와
    // (2) ForEach의 id: \.objectID로 차단.
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
        // 삭제 직후 KVO가 ForEach 배열 갱신보다 먼저 발화하면
        // non-optional @NSManaged 프로퍼티 접근에서 크래시가 나므로 가드한다.
        if category.isDeleted || category.managedObjectContext == nil {
            EmptyView()
        } else if isEditing {
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
                    .font(.pretendard(.title3))
                    .frame(width: 28)
                
                Text(category.name)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(category.activeTodoCount)")
                    .font(.pretendard(.subheadline))
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
