import XCTest

@testable import iKITTLogic

final class DashboardMathTests: XCTestCase {
    func testSpeedTextIsPaddedAndClamped() {
        XCTAssertEqual(DashboardMath.speedText(metersPerSecond: 0, unit: .kilometersPerHour), "000")
        XCTAssertEqual(DashboardMath.speedText(metersPerSecond: 10, unit: .kilometersPerHour), "036")
        XCTAssertEqual(DashboardMath.speedText(metersPerSecond: 10, unit: .milesPerHour), "022")
        XCTAssertEqual(DashboardMath.speedText(metersPerSecond: -20, unit: .kilometersPerHour), "000")
        XCTAssertEqual(DashboardMath.speedText(metersPerSecond: 1_000, unit: .kilometersPerHour), "999")
    }

    func testSpeedLEDCount() {
        XCTAssertEqual(DashboardMath.speedLEDCount(metersPerSecond: 0), 0)
        XCTAssertEqual(DashboardMath.speedLEDCount(metersPerSecond: 30), 16)
        XCTAssertEqual(DashboardMath.speedLEDCount(metersPerSecond: 60), 33)
        XCTAssertEqual(DashboardMath.speedLEDCount(metersPerSecond: 120), 33)
        XCTAssertEqual(DashboardMath.speedLEDCount(metersPerSecond: -10), 0)
    }

    func testFakeRPMCountStaysWithinBounds() {
        XCTAssertEqual(DashboardMath.fakeRPMCount(metersPerSecond: 0), 0)
        XCTAssertEqual(DashboardMath.fakeRPMCount(metersPerSecond: 100), 33)
        for speed in stride(from: 0.0, through: 80.0, by: 2.0) {
            let count = DashboardMath.fakeRPMCount(metersPerSecond: speed)
            XCTAssertGreaterThanOrEqual(count, 0)
            XCTAssertLessThanOrEqual(count, 33)
        }
    }

    func testMeterSegmentsClampAndFill() {
        XCTAssertEqual(DashboardMath.meterSegments(value: 25, min: 0, max: 50), 6)
        XCTAssertEqual(DashboardMath.meterSegments(value: 50, min: 0, max: 50), 12)
        XCTAssertEqual(DashboardMath.meterSegments(value: 0, min: 0, max: 50), 0)
        XCTAssertEqual(DashboardMath.meterSegments(value: -10, min: 0, max: 50), 0)
        XCTAssertEqual(DashboardMath.meterSegments(value: 100, min: 0, max: 50), 12)
        XCTAssertEqual(DashboardMath.meterSegments(value: 5, min: 10, max: 10), 0)
    }
}
