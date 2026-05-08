//
//  SoDoItWidgetBundle.swift
//  SoDoItWidget
//
//  Created by 한소희 on 4/25/26.
//

import WidgetKit
import SwiftUI

@main
struct SoDoItWidgetBundle: WidgetBundle {
    init() {
        PretendardFont.registerAll()
    }

    var body: some Widget {
        TodoListWidget()
    }
}
