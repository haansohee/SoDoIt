//
//  ColorPaletteView.swift
//  SoDoIt
//
//  Created by 한소희 on 2/26/26.
//

import SwiftUI

struct ColorPaletteView: View {
    @Binding var selectedHex: String
    
    static let presetColors: [(name: String, hex: String)] = [
        ("빨강", "#FF3B30"), ("주황", "#FF9500"), ("노랑", "#FFCC00"),
                  ("초록", "#34C759"), ("민트", "#00C7BE"), ("파랑", "#007AFF"),
                  ("남색", "#5856D6"), ("보라", "#AF52DE"), ("분홍", "#FF2D55"),
                  ("갈색", "#A2845E")
    ]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Self.presetColors, id: \.hex) { preset in
                colorButton(preset)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func colorButton(_ preset: (name: String, hex: String)) -> some View {
        Button {
            selectedHex = preset.hex
        } label: {
            Circle()
                .fill(Color(hex: preset.hex) ?? .gray)
                .frame(width: 36, height: 36)
                .overlay {
                    if selectedHex == preset.hex {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }
                .padding(4)
                .contentShape(Circle())
        }
        .accessibilityLabel(preset.name)
    }
}

#Preview {
    ColorPaletteView(selectedHex: .constant("#007AFF"))
        .padding()
}

