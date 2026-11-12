import Foundation

public enum DashboardMath {
    public static let maximumDashboardSpeed: Double = 60
    public static let dashboardLEDCount = 33
    public static let meterSegmentCount = 12

    public static func displaySpeed(metersPerSecond: Double, unit: SpeedUnit) -> Double {
        guard metersPerSecond.isFinite else { return 0 }
        return max(0, metersPerSecond) * unit.metersPerSecondMultiplier
    }

    public static func speedText(metersPerSecond: Double, unit: SpeedUnit) -> String {
        let value = min(999, displaySpeed(metersPerSecond: metersPerSecond, unit: unit))
        return String(format: "%03.0f", value)
    }

    public static func ledCount(
        metersPerSecond: Double,
        function: LEDFunction,
        totalLEDs: Int = dashboardLEDCount
    ) -> Int {
        guard totalLEDs > 0 else { return 0 }
        switch function {
        case .speed:
            return speedLEDCount(metersPerSecond: metersPerSecond, totalLEDs: totalLEDs)
        case .fakeRPM:
            return fakeRPMCount(metersPerSecond: metersPerSecond, totalLEDs: totalLEDs)
        }
    }

    public static func speedLEDCount(
        metersPerSecond: Double,
        totalLEDs: Int = dashboardLEDCount
    ) -> Int {
        guard metersPerSecond.isFinite, totalLEDs > 0 else { return 0 }
        let speed = max(0, metersPerSecond)
        let count = (speed * Double(totalLEDs) / maximumDashboardSpeed).rounded(.down)
        return min(totalLEDs, max(0, Int(count)))
    }

    public static func fakeRPMCount(
        metersPerSecond: Double,
        totalLEDs: Int = dashboardLEDCount
    ) -> Int {
        guard metersPerSecond.isFinite, totalLEDs > 0 else { return 0 }
        let kilometresPerHour = max(0, metersPerSecond) * 3.6
        guard kilometresPerHour > 0.5 else { return 0 }

        let gearSpan = 45.0
        let gear = min(5, Int(kilometresPerHour / gearSpan))
        let progressWithinGear = (kilometresPerHour - Double(gear) * gearSpan) / gearSpan
        let normalized = 0.18 + 0.82 * min(1, max(0, progressWithinGear))
        let count = (normalized * Double(totalLEDs)).rounded()
        return min(totalLEDs, max(1, Int(count)))
    }

    public static func meterSegments(
        value: Double,
        min minimum: Double,
        max maximum: Double,
        totalSegments: Int = meterSegmentCount
    ) -> Int {
        guard value.isFinite, maximum > minimum, totalSegments > 0 else { return 0 }
        let clamped = Swift.min(maximum, Swift.max(minimum, value))
        let fraction = (clamped - minimum) / (maximum - minimum)
        let count = (fraction * Double(totalSegments)).rounded(.down)
        return Swift.min(totalSegments, Swift.max(0, Int(count)))
    }
}
