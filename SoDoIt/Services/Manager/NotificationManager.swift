//
//  NotificationManager.swift
//  SoDoIt
//
//  Created by 한소희 on 4/21/26.
//

import UserNotifications
import OSLog

final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "sso.SoDoIt", category: "Notification")

    private init() {}

    // MARK: - 권한 요청

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                self.logger.error("알림 권한 요청 실패: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 알림 스케줄링

    func scheduleDueDateNotification(for todoID: UUID, title: String, dueDate: Date) {
        guard dueDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = "마감 시간이 되었습니다."
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(
            identifier: notificationID(for: todoID),
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                self.logger.error("알림 등록 실패: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 알림 취소

    func cancelNotification(for todoID: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [notificationID(for: todoID)])
    }

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }

    // MARK: - Private

    private func notificationID(for todoID: UUID) -> String {
        "todo-due-\(todoID.uuidString)"
    }
}
