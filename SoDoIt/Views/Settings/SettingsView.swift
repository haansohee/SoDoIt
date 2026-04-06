//
//  SettingsView.swift
//  SoDoIt
//
//  Created by 한소희 on 4/7/26.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "설정 기능이 곧 추가됩니다",
                systemImage: "gearshape.fill"
            )
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingsView()
}
