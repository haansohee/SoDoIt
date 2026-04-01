//
//  SmartFilterBar.swift
//  SoDoIt
//
//  Created by 한소희 on 3/30/26.
//

import SwiftUI

struct SmartFilterBar: View {
    let selectedFilter: SmartFilter
    let onSelect: (SmartFilter) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipButton(label: "전체", icon: "list.bullet", filter: .all)
                chipButton(label: "오늘", icon: "sun.max.fill", filter: .today)
                chipButton(label: "예정", icon: "calendar", filter: .upcoming)
                chipButton(label: "완료", icon: "checkmark.circle.fill", filter: .completed)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func chipButton(label: String, icon: String, filter: SmartFilter) -> some View {
        let isSelected = selectedFilter == filter
        Button {
            onSelect(filter)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color.clear)
            .foregroundStyle(isSelected ? .white : .accentColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.accentColor, lineWidth: 1)
            )
        }
    }
}
