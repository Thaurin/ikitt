import SwiftUI

struct LedMeterView: View {
    let activeSegments: Int
    var totalSegments = 12
    var spacing: CGFloat = 2

    private let activeColor = Color(red: 0.18, green: 0.55, blue: 0)
    private let inactiveColor = Color(red: 0.55, green: 0, blue: 0)

    var body: some View {
        GeometryReader { proxy in
            let gaps = CGFloat(max(0, totalSegments - 1)) * spacing
            let segmentWidth = max(1, (proxy.size.width - gaps) / CGFloat(max(1, totalSegments)))

            HStack(spacing: spacing) {
                ForEach(0..<totalSegments, id: \.self) { index in
                    Rectangle()
                        .fill(index < activeSegments ? activeColor : inactiveColor)
                        .frame(width: segmentWidth)
                }
            }
        }
        .frame(height: 5)
        .animation(.linear(duration: 0.2), value: activeSegments)
        .accessibilityHidden(true)
    }
}

struct LedArcView: View {
    let litCount: Int

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(DashboardLayout.ledPositions.enumerated()), id: \.offset) { index, position in
                Image(index < litCount ? "led_on3" : "led_off")
                    .resizable()
                    .interpolation(.high)
                    .frame(
                        width: DashboardLayout.ledSize.width,
                        height: DashboardLayout.ledSize.height
                    )
                    .position(
                        x: position.x + DashboardLayout.ledSize.width / 2,
                        y: position.y + DashboardLayout.ledSize.height / 2
                    )
            }
        }
        .frame(
            width: DashboardLayout.canvasSize.width,
            height: DashboardLayout.canvasSize.height
        )
        .accessibilityHidden(true)
    }
}
