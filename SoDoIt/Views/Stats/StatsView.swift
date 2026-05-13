//
//  StatsView.swift
//  SoDoIt
//
//  Created by 한소희 on 4/7/26.
//

import SwiftUI

struct StatsView: View {
    @State private var viewModel: StatsViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    init(viewModel: StatsViewModel = StatsViewModel()) {
        _viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summarySection
                    CompletionRateChart(
                        completedCount: viewModel.completedCount,
                        inProgressCount: viewModel.inProgressCount
                    )
                    WeeklyCompletionChart(data: viewModel.weeklyCompletion)
                    PriorityDistributionChart(data: viewModel.priorityDistribution)
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("통계")
            .onAppear {
                viewModel.refresh()
            }
        }
    }

    private var summarySection: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            StatSummaryCard(
                title: "오늘 완료",
                value: "\(viewModel.todayCompletedCount)",
                systemImage: "checkmark.circle.fill",
                tint: .green
            )
            StatSummaryCard(
                title: "전체 할 일",
                value: "\(viewModel.totalCount)",
                systemImage: "list.bullet",
                tint: .blue
            )
            StatSummaryCard(
                title: "완료율",
                value: viewModel.completionRateText,
                systemImage: "chart.pie.fill",
                tint: .purple
            )
            StatSummaryCard(
                title: "진행 중",
                value: "\(viewModel.inProgressCount)",
                systemImage: "hourglass",
                tint: .orange
            )
        }
    }

}

#Preview {
    StatsView(viewModel: StatsViewModel(preview: true))
}
