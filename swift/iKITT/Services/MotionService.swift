@preconcurrency import CoreMotion
import Observation
import UIKit

@MainActor
@Observable
final class MotionService {
    @ObservationIgnored private let motionManager = CMMotionManager()
    @ObservationIgnored private var pollTask: Task<Void, Never>?
    @ObservationIgnored private var lastAcceleration: CMAcceleration?
    @ObservationIgnored private var hysteresisExcited = false

    @ObservationIgnored var onShake: (@MainActor () -> Void)?
    private(set) var isRunning = false

    func start() {
        guard !isRunning, motionManager.isAccelerometerAvailable else { return }

        motionManager.accelerometerUpdateInterval = 0.05
        motionManager.startAccelerometerUpdates()
        isRunning = true
        lastAcceleration = nil
        hysteresisExcited = false

        pollTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                if let data = self.motionManager.accelerometerData {
                    self.process(data.acceleration)
                }
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
    }

    func stop() {
        pollTask?.cancel()
        pollTask = nil
        motionManager.stopAccelerometerUpdates()
        isRunning = false
        lastAcceleration = nil
        hysteresisExcited = false
    }

    private func process(_ acceleration: CMAcceleration) {
        defer { lastAcceleration = acceleration }
        guard let lastAcceleration else { return }

        if !hysteresisExcited, Self.isShaking(lastAcceleration, acceleration, threshold: 1.4) {
            hysteresisExcited = true
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            onShake?()
        } else if hysteresisExcited,
            !Self.isShaking(lastAcceleration, acceleration, threshold: 0.4)
        {
            hysteresisExcited = false
        }
    }

    private static func isShaking(
        _ previous: CMAcceleration,
        _ current: CMAcceleration,
        threshold: Double
    ) -> Bool {
        let deltaX = abs(previous.x - current.x)
        let deltaY = abs(previous.y - current.y)
        let deltaZ = abs(previous.z - current.z)

        return (deltaX > threshold && deltaY > threshold)
            || (deltaX > threshold && deltaZ > threshold)
            || (deltaY > threshold && deltaZ > threshold)
    }
}
