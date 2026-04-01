//
//  IconPickerView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/26/26.
//

import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String
    
    static let presetIcons: [(symbol: String, label: String)] = [
        ("folder.fill", "폴더"), ("book.fill", "책"), ("briefcase.fill", "서류가방"), ("cart.fill", "장바구니"),
        ("heart.fill", "하트"), ("star.fill", "별"), ("house.fill", "집"), ("person.fill", "사람"),
        ("gamecontroller.fill", "게임"), ("music.note", "음악"), ("airplane", "비행기"), ("car.fill", "자동차"),
        ("leaf.fill", "자연"), ("flame.fill", "불꽃"), ("lightbulb.fill", "아이디어"), ("graduationcap.fill", "학업"),
        ("dumbbell.fill", "운동"), ("fork.knife", "식사")
    ]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Self.presetIcons, id: \.symbol) { icon in
                iconButton(icon)
            }
        }
        .padding(.vertical, 4)
    }

    private func iconButton(_ icon: (symbol: String, label: String)) -> some View {
        Button {
            selectedIcon = icon.symbol
        } label: {
            Image(systemName: icon.symbol)
                .font(.title3)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedIcon == icon.symbol ? Color.accentColor.opacity(0.2) : Color.clear)
                )
                .foregroundStyle(selectedIcon == icon.symbol ? Color.accentColor : .secondary)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(icon.label)
    }
}

#Preview {
    IconPickerView(selectedIcon: .constant("folder.fill"))
        .padding()
}
