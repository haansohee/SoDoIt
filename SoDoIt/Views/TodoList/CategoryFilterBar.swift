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
                chipButton(
                    label: "전체",
                    icon: "list.bullet",
                    isSelected: selectedCategory == nil
                ) {
                    onSelect(nil)
                }

                ForEach(categories) { category in
                    let isSelected = selectedCategory?.id == category.id
                    chipButton(
                        label: category.name,
                        icon: category.iconName,
                        colorHex: category.colorHex,
                        isSelected: isSelected
                    ) {
                        onSelect(category)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func chipButton(
        label: String,
        icon: String,
        colorHex: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? chipColor(colorHex) : Color.clear)
            .foregroundStyle(isSelected ? .white : chipColor(colorHex))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(chipColor(colorHex), lineWidth: 1)
            )
        }
    }

    private func chipColor(_ hex: String?) -> Color {
        guard let hex, let color = Color(hex: hex) else { return .accentColor }
        return color
    }
}
