import XCTest

@testable import iKITTLogic

final class DashboardLayoutTests: XCTestCase {
    func testDashboardLEDArcHasThirtyThreeUniquePositions() {
        XCTAssertEqual(DashboardLayout.ledPositions.count, 33)
        XCTAssertEqual(Set(DashboardLayout.ledPositions.map { "\($0.x),\($0.y)" }).count, 33)
        XCTAssertEqual(DashboardLayout.ledPositions.first, LayoutPoint(x: 21, y: 135))
        XCTAssertEqual(DashboardLayout.ledPositions.last, LayoutPoint(x: 421, y: 72))
    }

    func testPortraitButtonsMatchTheVoiceboxLayout() {
        XCTAssertEqual(PortraitLayout.sideButtons.count, 8)
        XCTAssertEqual(PortraitLayout.pageButtons.count, 3)
        XCTAssertEqual(PortraitLayout.voiceboxRect, LayoutRect(x: 88, y: 89, width: 142, height: 190))
        XCTAssertEqual(Set(PortraitLayout.sideButtons.map(\.tag)), Set(1...8))
        XCTAssertEqual(Set(PortraitLayout.pageButtons.map(\.page)), Set(1...3))
    }

    func testMeterRectsAreOnTheDashboardCanvas() {
        let rects = [
            DashboardLayout.accuracyMeterRect,
            DashboardLayout.verticalAccuracyMeterRect,
            DashboardLayout.altitudeMeterRect,
            DashboardLayout.courseMeterRect,
        ]

        for rect in rects {
            XCTAssertGreaterThanOrEqual(rect.x, 0)
            XCTAssertGreaterThanOrEqual(rect.y, 0)
            XCTAssertLessThanOrEqual(rect.x + rect.width, DashboardLayout.canvasSize.width)
            XCTAssertLessThanOrEqual(rect.y + rect.height, DashboardLayout.canvasSize.height)
        }
    }
}
