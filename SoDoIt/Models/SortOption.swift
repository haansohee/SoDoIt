//
//  SortOption.swift
//  SoDoIt
//
//  Created by Claude on 4/5/26.
//

import Foundation

enum SortOption: CaseIterable {
    case priority, dueDate, createdDate

    var label: String {
        switch self {
        case .priority:    "우선순위"
        case .dueDate:     "마감일"
        case .createdDate: "생성일"
        }
    }

    var icon: String {
        switch self {
        case .priority:    "exclamationmark.triangle"
        case .dueDate:     "calendar"
        case .createdDate: "clock"
        }
    }

    var defaultAscending: Bool {
        switch self {
        case .priority:    true
        case .dueDate:     true
        case .createdDate: false
        }
    }
}
