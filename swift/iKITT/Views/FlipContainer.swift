import SwiftUI

struct FlipContainer<Front: View, Back: View>: View {
    let isFlipped: Bool
    let reduceMotion: Bool
    let front: Front
    let back: Back

    init(
        isFlipped: Bool,
        reduceMotion: Bool,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self.isFlipped = isFlipped
        self.reduceMotion = reduceMotion
        self.front = front()
        self.back = back()
    }

    var body: some View {
        ZStack {
            if reduceMotion {
                front
                    .opacity(isFlipped ? 0 : 1)
                    .allowsHitTesting(!isFlipped)

                back
                    .opacity(isFlipped ? 1 : 0)
                    .allowsHitTesting(isFlipped)
            } else {
                front
                    .rotation3DEffect(
                        .degrees(isFlipped ? -180 : 0),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.55
                    )
                    .opacity(isFlipped ? 0 : 1)
                    .allowsHitTesting(!isFlipped)

                back
                    .rotation3DEffect(
                        .degrees(isFlipped ? 0 : 180),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.55
                    )
                    .opacity(isFlipped ? 1 : 0)
                    .allowsHitTesting(isFlipped)
            }
        }
        .animation(
            reduceMotion ? .easeInOut(duration: 0.2) : .easeInOut(duration: 0.5),
            value: isFlipped
        )
    }
}
