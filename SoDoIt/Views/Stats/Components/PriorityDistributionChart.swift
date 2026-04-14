//
//  PriorityDistributionChart.swift
//  SoDoIt
//
//  Created by 한소희 on 4/7/26.
//

import SwiftUI
import Charts

struct PriorityDistributionChart: View {
    let data: [(priority: Priority, count: Int)]

    private var total: Int {
        data.map(\.count).reduce(0, +)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("우선순위별 분포")
                .font(.headline)

            if total == 0 {
                emptyState
            } else {
                Chart {
                    ForEach(data.reversed(), id: \.priority) { item in
                        BarMark(
                            x: .value("개수", item.count),
                            y: .value("우선순위", item.priority.title)
                        )
                        .foregroundStyle(item.priority.color.gradient)
                        .annotation(position: .trailing, alignment: .leading) {
                            Text("\(item.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .cornerRadius(4)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                    }
                }
                .frame(height: 140)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar.xaxis")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("등록된 할 일이 없습니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
    }
}

#Preview {
    PriorityDistributionChart(data: [
        (priority: .high, count: 5),
        (priority: .medium, count: 12),
        (priority: .low, count: 3)
    ])
    .padding()
    .background(Color(.systemGroupedBackground))
}
