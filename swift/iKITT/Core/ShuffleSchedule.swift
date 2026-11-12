import Foundation

public enum ShuffleSchedule {
    public static func delay(for interval: ShuffleInterval, randomUnit: Double) -> TimeInterval {
        let clampedUnit = min(1, max(0, randomUnit))
        let range = interval.range
        return range.lowerBound + (range.upperBound - range.lowerBound) * clampedUnit
    }

    public static func delay(
        for interval: ShuffleInterval,
        using generator: inout some RandomNumberGenerator
    ) -> TimeInterval {
        delay(for: interval, randomUnit: Double.random(in: 0..<1, using: &generator))
    }
}
