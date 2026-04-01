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
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            if let window = view.window,
               !(window.gestureRecognizers ?? []).contains(where: { $0 is KeyboardDismissTap }) {
                let tap = KeyboardDismissTap()
                tap.cancelsTouchesInView = false
                window.addGestureRecognizer(tap)
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

private class KeyboardDismissTap: UITapGestureRecognizer {
    init() {
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(dismiss))
    }

    @objc private func dismiss() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
