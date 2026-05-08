//
//  Font+Pretendard.swift
//  SoDoIt
//

import CoreText
import SwiftUI

enum PretendardFont {
    @MainActor private static var didRegister = false

    @MainActor
    static func registerAll() {
        guard !didRegister else { return }
        didRegister = true

        for name in ["Pretendard-Thin", "Pretendard-Regular", "Pretendard-SemiBold", "Pretendard-Bold"] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                assertionFailure("Pretendard font missing from bundle: \(name).ttf")
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                let description = error?.takeRetainedValue().localizedDescription ?? "unknown error"
                assertionFailure("Failed to register Pretendard font \(name): \(description)")
            }
        }
    }
}

extension Font {
    /// Pretendard 기반의 텍스트 스타일 폰트.
    /// `relativeTo:`로 Dynamic Type을 따라가도록 만든다.
    static func pretendard(_ style: TextStyle, weight: Weight = .regular) -> Font {
        .custom(pretendardName(for: weight), size: pretendardSize(for: style), relativeTo: style)
    }

    private static func pretendardName(for weight: Weight) -> String {
        switch weight {
        case .ultraLight, .thin, .light:
            return "Pretendard-Thin"
        case .medium, .semibold:
            return "Pretendard-SemiBold"
        case .bold, .heavy, .black:
            return "Pretendard-Bold"
        default:
            return "Pretendard-Regular"
        }
    }

    private static func pretendardSize(for style: TextStyle) -> CGFloat {
        switch style {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline, .body: return 17
        case .callout: return 16
        case .subheadline: return 15
        case .footnote: return 13
        case .caption: return 12
        case .caption2: return 11
        @unknown default: return 17
        }
    }
}
