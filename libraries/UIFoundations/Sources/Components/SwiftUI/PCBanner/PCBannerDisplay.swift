//
//  Created on 5/4/24.
//
//  Copyright (c) 2024 Proton AG
//
//  ProtonVPN is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonVPN is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonVPN.  If not, see <https://www.gnu.org/licenses/>.

#if os(iOS)

import SwiftUI

public enum BannerState: Equatable {
    case success(content: PCBannerContent)
    case error(content: PCBannerContent)
    case none

    public static func == (lhs: BannerState, rhs: BannerState) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success): return true
        case (.error, .error): return true
        case (.none, .none): return true
        default: return false
        }
    }
}

public struct PCBannerConfiguration {
    public enum Position {
        case top
        case bottom

        var alignment: Alignment {
            return switch self {
            case .top: .top
            case .bottom: .bottom
            }
        }

        var edge: Edge {
            return switch self {
            case .top: .top
            case .bottom: .bottom
            }
        }
    }
    public var position: Position
    public var animationDuration: CGFloat
    public var dismissDuration: TimeInterval?

    public init(
        position: Position = .top,
        animationDuration: CGFloat = 0.25,
        dismissDuration: TimeInterval? = 4
    ) {
        self.position = position
        self.animationDuration = animationDuration
        self.dismissDuration = dismissDuration
    }

    public static func `default`() -> PCBannerConfiguration {
        .init()
    }
}

@MainActor
public struct PCBannerDisplay: ViewModifier {
    @Binding public var bannerState: BannerState
    let configuration: PCBannerConfiguration

    @State private var animating: Bool = false
    @State private var dragYOffset: CGFloat = 0

    @State var timer: Timer?

    enum Constants {
        static let dragVelocityThreshold = 50.0
    }

    public func body(content: Content) -> some View {
        content
            .overlay(banner, alignment: configuration.position.alignment)
    }

    @ViewBuilder
    private var banner: some View {
        if bannerState != .none {
            ZStack {
                if animating {
                    PCBanner(
                        style: .constant(style),
                        content: .constant(content)
                    )
                    .padding()
                    .offset(y: offsetPosition)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: configuration.position.edge)),
                        removal: .opacity.combined(with: .move(edge: configuration.position.edge))
                    ))
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        withAnimation { dragYOffset = gesture.translation.height }
                    }
                    .onEnded { value in
                        let velocity = CGSize(
                            width: value.predictedEndLocation.x - value.location.x,
                            height: value.predictedEndLocation.y - value.location.y
                        )
                        checkDraggingDismissal(velocityHeight: velocity.height)
                    }
            )
            .onAppear {
                showBanner()
                if let dismissDuration = configuration.dismissDuration {
                    timer = Timer.scheduledTimer(withTimeInterval: dismissDuration, repeats: false, block: { _ in
                        DispatchQueue.main.async { dismissBanner() }
                    })
                }
            }
            .onDisappear {
                dismissBanner()
            }
        }
    }

    var style: PCBannerStyle {
        switch bannerState {
        case .success: return .init(style: .success)
        case .error: return .init(style: .error)
        case .none: return .init(style: .info)
        }
    }

    var content: PCBannerContent {
        switch bannerState {
        case .success(let content): return content
        case .error(let content): return content
        case .none: return .init(message: "")
        }
    }

    private func showBanner() {
        withAnimation(Animation.easeInOut(duration: configuration.animationDuration)) {
            animating = true
        }
    }

    private func dismissBanner() {
        timer?.invalidate()
        timer = nil
        withAnimation(Animation.easeInOut(duration: configuration.animationDuration)) {
            animating = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.animationDuration) {
            bannerState = .none
            dragYOffset = .zero
        }
    }

    private func checkDraggingDismissal(velocityHeight: CGFloat) {
        switch configuration.position {
        case .top where velocityHeight <= -Constants.dragVelocityThreshold,
             .bottom where velocityHeight > Constants.dragVelocityThreshold:
            dismissBanner()
        default:
            break
        }
    }

    private var offsetPosition: CGFloat {
        return switch configuration.position {
        case .top: min(0, dragYOffset)
        case .bottom: max(0, dragYOffset)
        }
    }
}

public extension View {
    @MainActor
    func bannerDisplayable(bannerState: Binding<BannerState>, configuration: PCBannerConfiguration) -> some View {
        modifier(PCBannerDisplay(bannerState: bannerState, configuration: configuration))
    }
}

#endif
