//
//  Priority.swift
//  SoDoIt
//
//  Created by 한소희 on 2/8/26.
//

import Foundation
import SwiftUI

enum Priority: Int16, CaseIterable {
    case high = 0
    case medium = 1
    case low = 2

    var title: String {
        switch self {
        case .high: return "높음"
        case .medium: return "보통"
        case .low: return "낮음"
        }
    }

    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }

    var iconName: String {
        switch self {
        case .high: return "exclamationmark.3"
        case .medium: return "exclamationmark.2"
        case .low: return "exclamationmark"
        }
    }
}
