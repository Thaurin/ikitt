import XCTest

@testable import iKITTLogic

final class ShuffleScheduleTests: XCTestCase {
    func testDelayUsesIntervalBounds() {
        XCTAssertEqual(ShuffleSchedule.delay(for: .fast, randomUnit: 0), 3)
        XCTAssertEqual(ShuffleSchedule.delay(for: .fast, randomUnit: 1), 7)
        XCTAssertEqual(ShuffleSchedule.delay(for: .normal, randomUnit: 0.5), 11)
        XCTAssertEqual(ShuffleSchedule.delay(for: .slow, randomUnit: 0), 30)
        XCTAssertEqual(ShuffleSchedule.delay(for: .slow, randomUnit: 1), 60)
    }

    func testDelayClampsOutOfRangeRandomUnits() {
        XCTAssertEqual(ShuffleSchedule.delay(for: .relaxed, randomUnit: -1), 10)
        XCTAssertEqual(ShuffleSchedule.delay(for: .relaxed, randomUnit: 2), 25)
    }

    func testGeneratedDelayStaysInsideInterval() {
        var generator = SeededGenerator(seed: 99)
        for interval in ShuffleInterval.allCases {
            for _ in 0..<100 {
                let delay = ShuffleSchedule.delay(for: interval, using: &generator)
                XCTAssertGreaterThanOrEqual(delay, interval.range.lowerBound)
                XCTAssertLessThanOrEqual(delay, interval.range.upperBound)
            }
        }
    }
}
