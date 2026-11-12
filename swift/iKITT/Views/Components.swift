import SwiftUI

struct AmbientBackground: View {
    let imageName: String

    var body: some View {
        GeometryReader { proxy in
            Image(imageName)
                .resizable()
                .interpolation(.high)
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .blur(radius: 38)
                .overlay {
                    Color.black.opacity(0.58)
                }
                .overlay {
                    RadialGradient(
                        colors: [Color.black.opacity(0.05), Color.black.opacity(0.72)],
                        center: .center,
                        startRadius: 30,
                        endRadius: max(proxy.size.width, proxy.size.height) * 0.72
                    )
                }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct ScaledCanvas<Content: View>: View {
    let designSize: CGSize
    let content: Content

    init(designSize: CGSize, @ViewBuilder content: () -> Content) {
        self.designSize = designSize
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            let scale = min(
                proxy.size.width / designSize.width,
                proxy.size.height / designSize.height
            )

            content
                .frame(width: designSize.width, height: designSize.height)
                .scaleEffect(scale)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
        }
    }
}

private struct ConsoleCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.85), radius: 24, x: 0, y: 14)
    }
}

extension View {
    func consoleCard(cornerRadius: CGFloat = 14) -> some View {
        modifier(ConsoleCardModifier(cornerRadius: cornerRadius))
    }
}
