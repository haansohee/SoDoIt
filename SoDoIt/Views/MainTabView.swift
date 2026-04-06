//
//  MainTabView.swift
//  SoDoIt
//
//  Created by 한소희 on 4/7/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodoListView()
                .tabItem {
                    Label("할 일", systemImage: "checklist")
                }

            StatsView()
                .tabItem {
                    Label("통계", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
