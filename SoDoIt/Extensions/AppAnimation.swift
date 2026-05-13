//
//  AppAnimation.swift
//  SoDoIt
//
//  Created by 한소희 on 4/16/26.
//

import SwiftUI

/// 앱 전반에서 사용하는 애니메이션 토큰
enum AppAnimation {
    /// 리스트/빈 상태 등 화면 단위 전환용
    static let listTransition: Animation = .easeInOut(duration: 0.25)

    /// 행(row) 내부 상태 변화(완료 토글 등)용
    static let rowStateChange: Animation = .easeInOut(duration: 0.2)
}
