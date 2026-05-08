//
//  Font+Pretendard.swift
//  SoDoItWidget
//
//  NOTE: SoDoIt/Extensions/Font+Pretendard.swift의 복사본입니다.
//  두 파일의 정의를 동일하게 유지해야 합니다.
//

import CoreText
import SwiftUI

enum PretendardFont {
    static func registerAll() {
        ["Pretendard-Thin", "Pretendard-Regular", "Pretendard-SemiBold", "Pretendard-Bold"]
            .forEach { name in
                guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { return }
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
    }
}

extension Font {
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
