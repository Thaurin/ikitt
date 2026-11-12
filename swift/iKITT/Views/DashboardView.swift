import Foundation
import SwiftUI
import UIKit

struct DashboardView: View {
    let model: AppModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var speedZoomed = false

    private var settings: AppSettings { model.settings }
    private var dashboard: DashboardModel { model.dashboard }

    private var ledCount: Int {
        DashboardMath.ledCount(
            metersPerSecond: dashboard.currentSpeed,
            function: settings.ledFunction
        )
    }

    private var speedText: String {
        DashboardMath.speedText(
            metersPerSecond: dashboard.currentSpeed,
            unit: settings.speedUnit
        )
    }

    var body: some View {
        ZStack {
            ScaledCanvas(designSize: DashboardLayout.canvasSize.cgSize) {
                dashboardCanvas
            }
            .padding(.horizontal, 8)

            if speedZoomed {
                zoomedSpeed
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(10)
            }
        }
        .onAppear {
            dashboard.start()
        }
        .onDisappear {
            dashboard.stop()
            speedZoomed = false
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                dashboard.start()
            } else {
                dashboard.stop()
            }
        }
        .onChange(of: ledCount) { oldValue, newValue in
            if settings.ledSoundEnabled, oldValue != newValue {
                model.clickPlayer.play()
            }
        }
        .sensoryFeedback(.selection, trigger: settings.speedUnit)
        .alert("GPS Error", isPresented: errorBinding) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            Button("Okay", role: .cancel) {
                dashboard.errorMessage = nil
            }
        } message: {
            Text(dashboard.errorMessage ?? "")
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { dashboard.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    dashboard.errorMessage = nil
                }
            }
        )
    }

    private var dashboardCanvas: some View {
        ZStack(alignment: .topLeading) {
            Image("dashBackground")
                .resizable()
                .interpolation(.high)
                .frame(
                    width: DashboardLayout.canvasSize.width,
                    height: DashboardLayout.canvasSize.height
                )

            LedArcView(litCount: ledCount)

            speedPanel

            unitButton

            statusLabel

            meter(dashboard.accuracySegments, rect: DashboardLayout.accuracyMeterRect)
            meter(dashboard.verticalAccuracySegments, rect: DashboardLayout.verticalAccuracyMeterRect)
            meter(dashboard.altitudeSegments, rect: DashboardLayout.altitudeMeterRect)
            meter(dashboard.courseSegments, rect: DashboardLayout.courseMeterRect)
        }
        .frame(
            width: DashboardLayout.canvasSize.width,
            height: DashboardLayout.canvasSize.height
        )
        .consoleCard(cornerRadius: 10)
    }

    private var speedPanel: some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.34, green: 0.027, blue: 0.027))

            Text(speedText)
                .font(.system(size: 54, weight: .bold, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(Color(red: 1, green: 0.08, blue: 0.03))
                .shadow(color: .red.opacity(0.75), radius: 7)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(
            width: DashboardLayout.speedBackgroundRect.width,
            height: DashboardLayout.speedBackgroundRect.height
        )
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                speedZoomed.toggle()
            }
        }
        .position(
            x: DashboardLayout.speedBackgroundRect.midX,
            y: DashboardLayout.speedBackgroundRect.midY
        )
        .accessibilityElement()
        .accessibilityLabel("Speed")
        .accessibilityValue(speedText)
        .accessibilityHint("Double-tap to zoom the speedometer")
    }

    private var unitButton: some View {
        Button {
            settings.speedUnit = settings.speedUnit.toggled
        } label: {
            Image(settings.speedUnit == .kilometersPerHour ? "kmh" : "mph")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(
                    width: DashboardLayout.unitImageRect.width,
                    height: DashboardLayout.unitImageRect.height
                )
                .frame(width: 90, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .position(
            x: DashboardLayout.unitImageRect.midX,
            y: DashboardLayout.unitImageRect.midY
        )
        .accessibilityLabel("Speed unit")
        .accessibilityValue(settings.speedUnit.title)
        .accessibilityHint("Toggles between kilometres per hour and miles per hour")
    }

    private var statusLabel: some View {
        Text(dashboard.statusText)
            .font(.system(size: 14))
            .foregroundStyle(Color.white)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(
                width: DashboardLayout.statusLabelRect.width,
                height: DashboardLayout.statusLabelRect.height
            )
            .opacity(dashboard.statusText.isEmpty ? 0 : 1)
            .position(
                x: DashboardLayout.statusLabelRect.midX,
                y: DashboardLayout.statusLabelRect.midY
            )
            .animation(.easeInOut(duration: 0.2), value: dashboard.statusText)
    }

    private func meter(_ segments: Int, rect: LayoutRect) -> some View {
        LedMeterView(activeSegments: segments)
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
    }

    private var zoomedSpeed: some View {
        GeometryReader { proxy in
            let fontSize = min(proxy.size.width, proxy.size.height) * 0.42

            ZStack {
                Color(red: 0.34, green: 0.027, blue: 0.027)
                    .opacity(0.97)

                Rectangle()
                    .strokeBorder(Color.red.opacity(0.35), lineWidth: 2)

                VStack(spacing: 14) {
                    Text(speedText)
                        .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                        .monospacedDigit()
                        .foregroundStyle(Color(red: 1, green: 0.08, blue: 0.03))
                        .shadow(color: .red.opacity(0.8), radius: 16)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)

                    Image(settings.speedUnit == .kilometersPerHour ? "kmh" : "mph")
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(height: 36)

                    Text("Double-tap to close")
                        .font(.footnote)
                        .foregroundStyle(Color.white.opacity(0.45))
                }
                .padding()
            }
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    speedZoomed = false
                }
            }
        }
        .ignoresSafeArea()
        .background(Color.black)
        .accessibilityElement()
        .accessibilityLabel("Zoomed speedometer")
        .accessibilityValue(speedText)
        .accessibilityAction {
            speedZoomed = false
        }
    }
}
