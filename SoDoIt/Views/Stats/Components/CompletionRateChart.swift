//
//  CompletionRateChart.swift
//  SoDoIt
//
//  Created by 한소희 on 4/9/26.
//

import SwiftUI
import Charts

struct CompletionRateChart: View {
    let completedCount: Int
    let inProgressCount: Int
    let completionRate: Double

    private var totalCount: Int {
        completedCount + inProgressCount
    }

    private var rateText: String {
        let percent = Int((completionRate * 100).rounded())
        return "\(percent)%"
    }

    private var segments: [Segment] {
        [
            Segment(label: "완료", count: completedCount, color: .accentColor),
            Segment(label: "진행 중", count: inProgressCount, color: Color(.systemGray4))
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("완료율")
                .font(.headline)

            HStack(spacing: 20) {
                chart
                    .frame(width: 140, height: 140)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(segments) { segment in
                        legendRow(segment)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    @ViewBuilder
    private var chart: some View {
        if totalCount == 0 {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 18)
                Text("0%")
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
            }
        } else {
            Chart(segments) { segment in
                SectorMark(
                    angle: .value("개수", segment.count),
                    innerRadius: .ratio(0.65),
                    angularInset: 1.5
                )
                .cornerRadius(4)
                .foregroundStyle(segment.color)
            }
            .chartBackground { _ in
                VStack(spacing: 2) {
                    Text(rateText)
                        .font(.title2.bold())
                        .monospacedDigit()
                    Text("완료")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func legendRow(_ segment: Segment) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(segment.color)
                .frame(width: 10, height: 10)
            Text(segment.label)
                .font(.subheadline)
            Spacer(minLength: 8)
            Text("\(segment.count)")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    private struct Segment: Identifiable {
        let label: String
        let count: Int
        let color: Color
        var id: String { label }
    }
}

#Preview("데이터 있음") {
    CompletionRateChart(completedCount: 18, inProgressCount: 7, completionRate: 18.0 / 25.0)
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("데이터 없음") {
    CompletionRateChart(completedCount: 0, inProgressCount: 0, completionRate: 0)
        .padding()
        .background(Color(.systemGroupedBackground))
}
