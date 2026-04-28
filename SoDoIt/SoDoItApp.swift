//
//  SoDoItApp.swift
//  SoDoIt
//
//  Created by 한소희 on 1/18/26.
//

import SwiftUI

@main
struct SoDoItApp: App {
    let coreDataManager = CoreDataManager.shared
    let notificationManager = NotificationManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.viewContext)
                .dismissKeyboardOnTap()
                .onAppear {
                    WidgetDataManager.shared.updateWidgetData()
                }
        }
    }
}
