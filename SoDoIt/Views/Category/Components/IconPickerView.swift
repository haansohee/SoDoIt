//
//  IconPickerView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/26/26.
//

import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    
    static let presetIcons: [String] = [
        "folder.fill", "book.fill", "briefcase.fill", "cart.fill",
        "heart.fill", "star.fill", "house.fill", "person.fill",
        "gamecontroller.fill", "music.note", "airplane", "car.fill",
        "leaf.fill", "flame.fill", "lightbulb.fill", "graduationcap.fill",
        "dumbbell.fill", "fork.knife"
    ]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Self.presetIcons, id: \.self) { icon in
                iconButton(icon)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func iconButton(_ icon: String) -> some View {
        Button {
            selectedIcon = icon
        } label: {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedIcon == icon ? Color.accentColor.opacity(0.2) : Color.clear)
                )
                .foregroundStyle(selectedIcon == icon ? Color.accentColor : .secondary)
        }
    }
}

#Preview {
    IconPickerView(selectedIcon: .constant("folder.fill"))
        .padding()
}
