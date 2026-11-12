@preconcurrency import CoreLocation
import Foundation
import Observation

@MainActor
@Observable
final class DashboardModel: NSObject, @preconcurrency CLLocationManagerDelegate {
    @ObservationIgnored private let manager = CLLocationManager()
    @ObservationIgnored private var updatesTask: Task<Void, Never>?
    @ObservationIgnored private var speedTask: Task<Void, Never>?
    @ObservationIgnored private var updateGeneration = 0
    @ObservationIgnored private var skippedUpdates = 0

    var currentSpeed: Double = 0
    var accuracySegments = 0
    var verticalAccuracySegments = 0
    var altitudeSegments = 0
    var courseSegments = 0
    var statusText = "Waiting for GPS information..."
    var errorMessage: String?
    var isRunning = false
    var reducesMotion = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        skippedUpdates = 0

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdates()
        case .denied, .restricted:
            handleDenied()
        @unknown default:
            break
        }
    }

    func stop() {
        updateGeneration += 1
        updatesTask?.cancel()
        updatesTask = nil
        speedTask?.cancel()
        speedTask = nil
        isRunning = false
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard isRunning else { return }

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdates()
        case .denied, .restricted:
            handleDenied()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    private func startUpdates() {
        guard updatesTask == nil else { return }
        skippedUpdates = 0
        statusText = currentSpeed > 0 ? "" : "Waiting for GPS information..."

        updateGeneration += 1
        let generation = updateGeneration

        updatesTask = Task { @MainActor [weak self] in
            defer {
                if let self, self.updateGeneration == generation {
                    self.updatesTask = nil
                }
            }

            do {
                for try await update in CLLocationUpdate.liveUpdates(.automotiveNavigation) {
                    guard let self else { return }

                    if update.authorizationDenied {
                        self.handleDenied()
                        return
                    }
                    if update.locationUnavailable {
                        continue
                    }
                    if let location = update.location {
                        self.handle(location)
                    }
                }
            } catch {
                guard !Task.isCancelled else { return }
                self?.setError(error.localizedDescription)
            }
        }
    }

    private func handle(_ location: CLLocation) {
        if skippedUpdates < 2 {
            skippedUpdates += 1
            return
        }

        if location.speed >= 0 {
            smoothSpeed(to: location.speed)
        }

        accuracySegments = DashboardMath.meterSegments(
            value: 50 - location.horizontalAccuracy,
            min: 0,
            max: 50
        )
        verticalAccuracySegments =
            location.verticalAccuracy >= 0
            ? DashboardMath.meterSegments(value: 50 - location.verticalAccuracy, min: 0, max: 50)
            : 0
        altitudeSegments = DashboardMath.meterSegments(
            value: location.altitude,
            min: 0,
            max: 300
        )
        courseSegments = DashboardMath.meterSegments(
            value: location.course,
            min: 0,
            max: 359
        )

        if location.horizontalAccuracy <= 25 || location.speed > 0 {
            statusText = ""
        }
    }

    private func smoothSpeed(to speed: Double) {
        let target = max(0, speed)
        speedTask?.cancel()

        guard !reducesMotion else {
            currentSpeed = target
            return
        }

        let start = currentSpeed
        guard abs(target - start) > 0.01 else {
            currentSpeed = target
            return
        }

        speedTask = Task { @MainActor [weak self] in
            let steps = 20
            for step in 1...steps {
                try? await Task.sleep(for: .milliseconds(50))
                guard !Task.isCancelled, let self else { return }
                let progress = Double(step) / Double(steps)
                self.currentSpeed = start + (target - start) * progress
            }
        }
    }

    private func handleDenied() {
        statusText = "Location access denied."
        if errorMessage == nil {
            errorMessage =
                "Location access was denied. Enable location access for iKITT in Settings to use the dashboard."
        }
        updatesTask?.cancel()
        updatesTask = nil
        isRunning = false
    }

    private func setError(_ message: String) {
        statusText = message
        if errorMessage == nil {
            errorMessage = message
        }
        updatesTask?.cancel()
        updatesTask = nil
        isRunning = false
    }
}
