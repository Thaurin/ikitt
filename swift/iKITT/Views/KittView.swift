import SwiftUI

struct KittView: View {
    let model: AppModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if model.voiceboxZoomed {
                VoiceboxZoomView(model: model)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(20)
            } else {
                VStack(spacing: 0) {
                    logoBar
                    ScaledCanvas(designSize: PortraitLayout.canvasSize.cgSize) {
                        console
                    }
                    .padding(.horizontal, 8)
                    bottomBar
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: model.voiceboxZoomed)
        .sensoryFeedback(.selection, trigger: model.selectedPage)
    }

    private var logoBar: some View {
        Image("logo")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: 168)
            .opacity(model.showsLogo ? 1 : 0)
            .offset(y: (model.showsLogo || reduceMotion) ? 0 : -28)
            .frame(maxWidth: .infinity)
            .frame(height: 62)
            .animation(.easeOut(duration: 0.75), value: model.showsLogo)
            .accessibilityHidden(true)
    }

    private var bottomBar: some View {
        HStack {
            Button {
                model.openPanel(.settings)
            } label: {
                Image("icon_config")
                    .renderingMode(.template)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 26, height: 28)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Settings")

            Spacer()

            Button {
                model.openPanel(.info)
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Info")
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.white.opacity(0.45))
        .frame(height: 58)
        .padding(.horizontal, 28)
        .opacity(model.controlsVisible ? 1 : 0)
        .disabled(!model.controlsVisible)
        .animation(.easeInOut(duration: 0.4), value: model.controlsVisible)
    }

    private var console: some View {
        ZStack(alignment: .topLeading) {
            Image("kittBackground")
                .resizable()
                .interpolation(.high)
                .frame(
                    width: PortraitLayout.canvasSize.width,
                    height: PortraitLayout.canvasSize.height
                )

            ForEach(PortraitLayout.sideButtons) { button in
                Image(button.imageName)
                    .resizable()
                    .interpolation(.high)
                    .frame(
                        width: button.imageRect.width,
                        height: button.imageRect.height
                    )
                    .opacity(isButtonImageVisible(button) ? 1 : 0)
                    .position(x: button.imageRect.midX, y: button.imageRect.midY)
                    .allowsHitTesting(false)
            }

            ForEach(PortraitLayout.sideButtons) { button in
                Button {
                    model.pressSideButton(tag: button.tag)
                } label: {
                    Color.clear
                        .frame(width: button.hitRect.width, height: button.hitRect.height)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .position(x: button.hitRect.midX, y: button.hitRect.midY)
                .disabled(!model.controlsVisible)
                .accessibilityLabel(Text(button.title))
            }

            ForEach(PortraitLayout.pageButtons) { page in
                Button {
                    model.selectPage(page.page)
                } label: {
                    Image(page.imageName)
                        .resizable()
                        .interpolation(.high)
                        .frame(width: page.rect.width, height: page.rect.height)
                        .opacity(pageOpacity(for: page.page))
                }
                .buttonStyle(.plain)
                .position(x: page.rect.midX, y: page.rect.midY)
                .disabled(!model.controlsVisible)
                .accessibilityLabel(Text(page.title))
            }

            voicebox
                .frame(
                    width: PortraitLayout.voiceboxRect.width,
                    height: PortraitLayout.voiceboxRect.height
                )
                .position(
                    x: PortraitLayout.voiceboxRect.midX,
                    y: PortraitLayout.voiceboxRect.midY
                )
        }
        .frame(
            width: PortraitLayout.canvasSize.width,
            height: PortraitLayout.canvasSize.height
        )
        .animation(.easeInOut(duration: 0.25), value: model.revealedRows)
        .animation(.easeInOut(duration: 0.2), value: model.litButtonTag)
        .animation(.easeInOut(duration: 0.2), value: model.selectedPage)
        .animation(.easeInOut(duration: 0.65), value: model.controlsVisible)
        .consoleCard()
    }

    private var voicebox: some View {
        Image("voicebox\(model.audio.voiceboxFrameIndex)")
            .resizable()
            .interpolation(.high)
            .frame(
                width: PortraitLayout.voiceboxRect.width,
                height: PortraitLayout.voiceboxRect.height
            )
            .contentShape(Rectangle())
            .gesture(
                TapGesture(count: 2)
                    .onEnded { _ in model.toggleVoiceboxZoom() }
                    .exclusively(
                        before: TapGesture()
                            .onEnded { _ in model.playRandom() }
                    )
            )
            .accessibilityElement()
            .accessibilityLabel("KITT voicebox")
            .accessibilityHint("Tap to play a random sample. Double-tap to zoom.")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction {
                model.playRandom()
            }
            .accessibilityAction(named: "Zoom") {
                model.toggleVoiceboxZoom()
            }
    }

    private func isButtonImageVisible(_ button: SideButtonLayout) -> Bool {
        model.revealedRows.contains(button.row) && model.litButtonTag != button.tag
    }

    private func pageOpacity(for page: Int) -> Double {
        guard model.controlsVisible else { return 0 }
        return model.selectedPage == page ? 1 : 0.03
    }
}

private struct VoiceboxZoomView: View {
    let model: AppModel

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black

                Image("voicebox\(model.audio.voiceboxFrameIndex)")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()

                VStack {
                    Spacer()
                    Text("Tap for a random sample. Double-tap to close.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white.opacity(0.5))
                        .padding(.bottom, 36)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                TapGesture(count: 2)
                    .onEnded { _ in model.toggleVoiceboxZoom() }
                    .exclusively(
                        before: TapGesture()
                            .onEnded { _ in model.playRandom() }
                    )
            )
        }
        .ignoresSafeArea()
        .background(Color.black)
        .accessibilityElement()
        .accessibilityLabel("Zoomed KITT voicebox")
        .accessibilityHint("Tap to play a random sample. Double-tap to zoom out.")
        .accessibilityAction {
            model.playRandom()
        }
        .accessibilityAction(named: "Zoom out") {
            model.toggleVoiceboxZoom()
        }
    }
}
