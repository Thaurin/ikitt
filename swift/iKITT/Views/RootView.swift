import SwiftUI
import UIKit

struct RootView: View {
    let model: AppModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isLandscape = false
    @State private var lastPanel: AppModel.Panel = .settings

    var body: some View {
        GeometryReader { proxy in
            let landscape = proxy.size.width > proxy.size.height

            ZStack {
                Color.black
                    .ignoresSafeArea()

                AmbientBackground(imageName: landscape ? "dashBackground" : "kittBackground")

                if landscape {
                    DashboardView(model: model)
                } else {
                    FlipContainer(
                        isFlipped: model.activePanel != .none,
                        reduceMotion: reduceMotion
                    ) {
                        KittView(model: model)
                    } back: {
                        panelView
                    }
                }
            }
            .onChange(of: landscape, initial: true) { _, newValue in
                isLandscape = newValue
                model.setPortrait(!newValue)
                model.dashboard.reducesMotion = reduceMotion
                updateIdleTimer(landscape: newValue, active: scenePhase == .active)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onChange(of: scenePhase, initial: true) { _, phase in
            model.setAppActive(phase == .active)
            updateIdleTimer(landscape: isLandscape, active: phase == .active)
        }
        .onChange(of: reduceMotion) { _, newValue in
            model.dashboard.reducesMotion = newValue
        }
        .onChange(of: model.settings.shuffleEnabled) { _, _ in
            model.settingsDidChange()
        }
        .onChange(of: model.settings.shuffleInterval) { _, _ in
            model.settingsDidChange()
        }
        .onChange(of: model.activePanel) { _, newValue in
            if newValue != .none {
                lastPanel = newValue
            }
        }
    }

    @ViewBuilder
    private var panelView: some View {
        Group {
            switch displayedPanel {
            case .info:
                InfoView(onDismiss: { model.closePanel() })
            case .settings:
                SettingsView(settings: model.settings, onDismiss: { model.closePanel() })
            case .none:
                Color.black
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }

    private var displayedPanel: AppModel.Panel {
        model.activePanel == .none ? lastPanel : model.activePanel
    }

    private func updateIdleTimer(landscape: Bool, active: Bool) {
        UIApplication.shared.isIdleTimerDisabled = landscape && active
    }
}
