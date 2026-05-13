//
//  ChipButton.swift
//  SoDoIt
//
//  Created by 한소희 on 4/1/26.
//

import SwiftUI

struct ChipButton: View {
    let label: String
    let icon: String
    var color: Color = .accentColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.pretendard(.caption))
                Text(label)
                    .font(.pretendard(.subheadline))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? color : Color.clear)
            .foregroundStyle(isSelected ? .white : color)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(color, lineWidth: 1)
            )
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
