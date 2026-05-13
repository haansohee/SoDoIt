//
//  WidgetTodoItem.swift
//  SoDoItWidget
//
//  Created by 한소희 on 4/25/26.
//
//  NOTE: SoDoIt/Models/WidgetTodoItem.swift의 복사본입니다.
//  두 파일의 구조체 정의를 동일하게 유지해야 합니다.
//

import Foundation

/// 메인 앱 ↔ 위젯 간 공유되는 할 일 모델 (Codable)
struct WidgetTodoItem: Codable, Identifiable {
    let id: UUID
    let title: String
    let priority: Int16
    let dueDate: Date?
    let categoryName: String?
    let categoryColorHex: String?
}

/// App Group 공유 상수
enum AppGroup {
    static let identifier = "group.sso.SoDoIt"
    static let todosKey = "widget_todos"
    static let statsKey = "widget_stats"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: identifier)
    }
}

/// 위젯에 표시할 요약 통계
struct WidgetStats: Codable {
    let totalCount: Int
    let completedCount: Int
    let todayCount: Int
}
