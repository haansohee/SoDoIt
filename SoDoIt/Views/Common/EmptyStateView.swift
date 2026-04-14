//
//  EmptyStateView.swift
//  SoDoIt
//
//  Created by 한소희 on 4/14/26.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let description: String?
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        title: String,
        systemImage: String,
        description: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            if let description {
                Text(description)
            }
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview("기본") {
    EmptyStateView(
        title: "할 일이 없습니다",
        systemImage: "checklist",
        description: "+ 버튼을 눌러 새로운 할 일을 추가하세요"
    )
}

#Preview("액션 버튼") {
    EmptyStateView(
        title: "카테고리가 없습니다",
        systemImage: "folder",
        description: "할 일을 분류할 카테고리를 먼저 추가하세요",
        actionTitle: "카테고리 추가",
        action: {}
    )
}
