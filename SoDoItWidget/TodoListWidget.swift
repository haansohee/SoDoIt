//
//  TodoListWidget.swift
//  SoDoItWidget
//
//  Created by 한소희 on 4/25/26.
//

import WidgetKit
import SwiftUI

struct TodoListWidget: Widget {
    let kind: String = "TodoListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoWidgetProvider()) { entry in
            TodoWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("오늘의 할 일")
        .description("진행 중인 할 일을 홈 화면에서 바로 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
