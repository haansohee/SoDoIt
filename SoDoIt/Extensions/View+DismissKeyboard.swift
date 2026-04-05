//
//  View+DismissKeyboard.swift
//  SoDoIt
//
//  Created by 한소희 on 3/30/26.
//

import SwiftUI

extension View {
    func dismissKeyboardOnTap() -> some View {
        background(WindowKeyboardDismissInstaller())
    }
}

private struct WindowKeyboardDismissInstaller: UIViewRepresentable {
    func makeUIView(context: Context) -> KeyboardDismissInstallerView {
        KeyboardDismissInstallerView()
    }

    func updateUIView(_ uiView: KeyboardDismissInstallerView, context: Context) {}
}

private class KeyboardDismissInstallerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let window,
              !(window.gestureRecognizers ?? []).contains(where: { $0 is KeyboardDismissTap }) else { return }
        let tap = KeyboardDismissTap()
        tap.cancelsTouchesInView = false
        window.addGestureRecognizer(tap)
    }
}

private class KeyboardDismissTap: UITapGestureRecognizer {
    private let dismissTarget = DismissTarget()

    init() {
        super.init(target: nil, action: nil)
        addTarget(dismissTarget, action: #selector(DismissTarget.dismiss))
    }

    private class DismissTarget: NSObject {
        @objc func dismiss() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }
}
