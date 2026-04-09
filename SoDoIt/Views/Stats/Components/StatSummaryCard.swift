//
//  StatSummaryCard.swift
//  SoDoIt
//
//  Created by 한소희 on 4/7/26.
//

import SwiftUI

struct StatSummaryCard: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.subheadline)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        StatSummaryCard(title: "오늘 완료", value: "5", systemImage: "checkmark.circle.fill", tint: .green)
        StatSummaryCard(title: "전체 할 일", value: "42", systemImage: "list.bullet", tint: .blue)
        StatSummaryCard(title: "완료율", value: "67%", systemImage: "chart.pie.fill", tint: .purple)
        StatSummaryCard(title: "진행 중", value: "14", systemImage: "hourglass", tint: .orange)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
