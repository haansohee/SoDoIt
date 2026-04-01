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
                ChipButton(label: "전체", icon: "list.bullet", isSelected: selectedFilter == .all) {
                    onSelect(.all)
                }
                ChipButton(label: "오늘", icon: "sun.max.fill", isSelected: selectedFilter == .today) {
                    onSelect(.today)
                }
                ChipButton(label: "예정", icon: "calendar", isSelected: selectedFilter == .upcoming) {
                    onSelect(.upcoming)
                }
                ChipButton(label: "완료", icon: "checkmark.circle.fill", isSelected: selectedFilter == .completed) {
                    onSelect(.completed)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}
