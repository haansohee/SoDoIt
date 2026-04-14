//
//  SettingsViewModel.swift
//  SoDoIt
//
//  Created by 한소희 on 4/14/26.
//

import Foundation
import Observation
import OSLog

@Observable
final class SettingsViewModel {
    private(set) var isResetting: Bool = false
    var resetError: String?

    var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private let todoRepository: TodoRepository
    private let categoryRepository: CategoryRepository
    private let logger = Logger(subsystem: "sso.SoDoIt", category: "Settings")

    init(
        todoRepository: TodoRepository = TodoRepository(),
        categoryRepository: CategoryRepository = CategoryRepository()
    ) {
        self.todoRepository = todoRepository
        self.categoryRepository = categoryRepository
    }

    /// preview용 편의 이니셜라이저
    convenience init(preview: Bool) {
        self.init(
            todoRepository: TodoRepository(context: CoreDataManager.preview.viewContext),
            categoryRepository: CategoryRepository(context: CoreDataManager.preview.viewContext)
        )
    }

    /// 모든 할 일과 카테고리를 삭제합니다.
    func resetAllData() async {
        isResetting = true
        defer { isResetting = false }

        await Task.yield()

        do {
            try todoRepository.deleteAllTodos()
            try categoryRepository.deleteAllCategories()
        } catch {
            logger.error("데이터 초기화 실패: \(error.localizedDescription)")
            resetError = "데이터 초기화에 실패했습니다. 다시 시도해 주세요."
        }
    }
}
