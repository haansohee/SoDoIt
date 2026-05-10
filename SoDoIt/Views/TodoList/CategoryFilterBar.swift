//
//  CategoryFilterBar.swift
//  SoDoIt
//
//  Created by 한소희 on 3/12/26.
//

import SwiftUI

struct CategoryFilterBar: View {
    let categories: [Category]
    let selectedCategory: Category?
    let onSelect: (Category?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ChipButton(
                    label: "전체",
                    icon: "list.bullet",
                    isSelected: selectedCategory == nil
                ) {
                    onSelect(nil)
                }

                ForEach(categories, id: \.objectID) { category in
                    ChipButton(
                        label: category.name,
                        icon: category.iconName,
                        color: chipColor(category.colorHex),
                        isSelected: selectedCategory?.id == category.id
                    ) {
                        onSelect(category)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    private func chipColor(_ hex: String?) -> Color {
        guard let hex else { return .accentColor }
        return Color(hex: hex) ?? .accentColor
    }
}
