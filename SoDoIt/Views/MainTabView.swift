//
//  MainTabView.swift
//  SoDoIt
//
//  Created by 한소희 on 4/7/26.
//

import SwiftUI

struct MainTabView: View {
    private enum Tab: String, CaseIterable {
        case todo, stats, settings
    }

    @State private var selectedTab: Tab = .todo

    var body: some View {
        TabView(selection: $selectedTab) {
            TodoListView()
                .tabItem {
                    Label("할 일", systemImage: "checklist")
                }
                .tag(Tab.todo)

            StatsView()
                .tabItem {
                    Label("통계", systemImage: "chart.bar.fill")
                }
                .tag(Tab.stats)

            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, CoreDataManager.preview.viewContext)
}
