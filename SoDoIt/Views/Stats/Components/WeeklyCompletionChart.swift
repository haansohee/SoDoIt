//
//  WeeklyCompletionChart.swift
//  SoDoIt
//
//  Created by 한소희 on 4/7/26.
//

import SwiftUI
import Charts

struct WeeklyCompletionChart: View {
    let data: [(date: Date, count: Int)]

    private var maxCount: Int {
        max(data.map(\.count).max() ?? 0, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주간 완료 추이")
                .font(.pretendard(.headline, weight: .semibold))

            Chart {
                ForEach(data, id: \.date) { item in
                    BarMark(
                        x: .value("날짜", item.date, unit: .day),
                        y: .value("완료 개수", item.count)
                    )
                    .foregroundStyle(Color.accentColor.gradient)
                    .cornerRadius(4)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: maxCount > 3 ? 4 : maxCount + 1))
            }
            .frame(height: 180)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    let today = Calendar.current.startOfDay(for: Date())
    let sample: [(date: Date, count: Int)] = (0..<7).reversed().map { offset in
        (date: Calendar.current.date(byAdding: .day, value: -offset, to: today)!, count: Int.random(in: 0...8))
    }

    return WeeklyCompletionChart(data: sample)
        .padding()
        .background(Color(.systemGroupedBackground))
}
