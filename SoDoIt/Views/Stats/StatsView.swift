//
//  StatsView.swift
//  SoDoIt
//
//  Created by 한소희 on 4/7/26.
//

import SwiftUI

struct StatsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "통계 기능이 곧 추가됩니다",
                systemImage: "chart.bar.fill"
            )
            .navigationTitle("통계")
        }
    }
}

#Preview {
    StatsView()
}
