//
//  TransparentBlurView.swift
//  Zob Squat Counter
//
//  Created on 18/04/2025.
//

import SwiftUI

struct TransparentBlurView: UIViewRepresentable {
    var removeAllFilters: Bool = false

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        DispatchQueue.main.async {
            if let backdropLayer = uiView.layer.sublayers?.first {
                if removeAllFilters {
                    backdropLayer.filters = []
                } else {
                    // Removing all filters except "gaussianBlur"
                    backdropLayer.filters?.removeAll(where: { filter in
                        String(describing: filter) != "gaussianBlur"
                    })
                }
            }
        }
    }
}

// MARK: - Stats Blur Container
struct StatsBlurContainer<Content: View>: View {
    var isVisible: Bool
    var isFadingOut: Bool
    var content: Content
    var onUnlockTapped: () -> Void

    init(isVisible: Bool, isFadingOut: Bool = false, onUnlockTapped: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.isVisible = isVisible
        self.isFadingOut = isFadingOut
        self.onUnlockTapped = onUnlockTapped
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Content
            content

            // Blur overlay
            if !isVisible {
                TransparentBlurView(removeAllFilters: isFadingOut)
                    .opacity(isFadingOut ? 0 : 1)

                // Unlock button
                Button {
                    onUnlockTapped()
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "eye")
                            .font(.system(size: 24))
                            .foregroundStyle(.indigo)

                        Text("Unlock Stats")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.indigo)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .scaleEffect(isFadingOut ? 0.5 : 1)
                .opacity(isFadingOut ? 0 : 1)
            }
        }
        .animation(.spring(response: 0.3), value: isFadingOut)
        .animation(.spring(response: 0.3), value: isVisible)
    }
}

// MARK: - SwiftUI Usage Extension

extension View {
    func statsBlurContainer(isVisible: Bool, isFadingOut: Bool = false, onUnlockTapped: @escaping () -> Void) -> some View {
        StatsBlurContainer(isVisible: isVisible, isFadingOut: isFadingOut, onUnlockTapped: onUnlockTapped) {
            self
        }
    }
}
