import Foundation

public struct LayoutPoint: Equatable, Sendable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct LayoutSize: Equatable, Sendable {
    public let width: Double
    public let height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}

public struct LayoutRect: Equatable, Sendable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    public var midX: Double { x + width / 2 }
    public var midY: Double { y + height / 2 }
}

public struct SideButtonLayout: Equatable, Sendable, Identifiable {
    public let tag: Int
    public let row: Int
    public let imageName: String
    public let imageRect: LayoutRect
    public let hitRect: LayoutRect
    public let title: String

    public var id: Int { tag }
}

public struct PageButtonLayout: Equatable, Sendable, Identifiable {
    public let page: Int
    public let imageName: String
    public let rect: LayoutRect
    public let title: String

    public var id: Int { page }
}

public enum PortraitLayout {
    public static let canvasSize = LayoutSize(width: 320, height: 480)
    public static let logoRect = LayoutRect(x: 101, y: 47, width: 120, height: 22)
    public static let voiceboxRect = LayoutRect(x: 88, y: 89, width: 142, height: 190)
    public static let configButtonRect = LayoutRect(x: 20, y: 435, width: 32, height: 31)
    public static let infoButtonRect = LayoutRect(x: 282, y: 441, width: 18, height: 19)

    public static let sideButtons: [SideButtonLayout] = [
        SideButtonLayout(
            tag: 1, row: 0, imageName: "button_L1",
            imageRect: LayoutRect(x: 8, y: 151, width: 84, height: 59),
            hitRect: LayoutRect(x: 21, y: 161, width: 58, height: 37),
            title: "Air"
        ),
        SideButtonLayout(
            tag: 2, row: 1, imageName: "button_L2",
            imageRect: LayoutRect(x: 9, y: 209, width: 81, height: 62),
            hitRect: LayoutRect(x: 21, y: 221, width: 58, height: 37),
            title: "Oil"
        ),
        SideButtonLayout(
            tag: 3, row: 2, imageName: "button_L3",
            imageRect: LayoutRect(x: 9, y: 272, width: 81, height: 62),
            hitRect: LayoutRect(x: 21, y: 284, width: 58, height: 37),
            title: "P1"
        ),
        SideButtonLayout(
            tag: 4, row: 3, imageName: "button_L4",
            imageRect: LayoutRect(x: 9, y: 332, width: 81, height: 62),
            hitRect: LayoutRect(x: 21, y: 343, width: 58, height: 37),
            title: "P2"
        ),
        SideButtonLayout(
            tag: 5, row: 0, imageName: "button_R1",
            imageRect: LayoutRect(x: 234, y: 149, width: 81, height: 62),
            hitRect: LayoutRect(x: 246, y: 161, width: 58, height: 37),
            title: "S1"
        ),
        SideButtonLayout(
            tag: 6, row: 1, imageName: "button_R2",
            imageRect: LayoutRect(x: 234, y: 209, width: 81, height: 62),
            hitRect: LayoutRect(x: 246, y: 221, width: 58, height: 37),
            title: "S2"
        ),
        SideButtonLayout(
            tag: 7, row: 2, imageName: "button_R3",
            imageRect: LayoutRect(x: 234, y: 273, width: 81, height: 62),
            hitRect: LayoutRect(x: 246, y: 285, width: 58, height: 37),
            title: "P3"
        ),
        SideButtonLayout(
            tag: 8, row: 3, imageName: "button_R4",
            imageRect: LayoutRect(x: 234, y: 332, width: 81, height: 62),
            hitRect: LayoutRect(x: 246, y: 343, width: 58, height: 37),
            title: "P4"
        ),
    ]

    public static let pageButtons: [PageButtonLayout] = [
        PageButtonLayout(
            page: 1, imageName: "button_red",
            rect: LayoutRect(x: 102, y: 280, width: 111, height: 36),
            title: "Auto Cruise"
        ),
        PageButtonLayout(
            page: 2, imageName: "button_yellow",
            rect: LayoutRect(x: 101, y: 324, width: 113, height: 38),
            title: "Normal Cruise"
        ),
        PageButtonLayout(
            page: 3, imageName: "button_blue",
            rect: LayoutRect(x: 101, y: 370, width: 113, height: 38),
            title: "Pursuit"
        ),
    ]
}

public enum DashboardLayout {
    public static let canvasSize = LayoutSize(width: 480, height: 320)
    public static let speedBackgroundRect = LayoutRect(x: 190, y: 87, width: 145, height: 65)
    public static let unitImageRect = LayoutRect(x: 348, y: 111, width: 68, height: 33)
    public static let statusLabelRect = LayoutRect(x: 20, y: 302, width: 440, height: 18)

    public static let accuracyMeterRect = LayoutRect(x: 30, y: 235, width: 150, height: 5)
    public static let verticalAccuracyMeterRect = LayoutRect(x: 300, y: 235, width: 150, height: 5)
    public static let altitudeMeterRect = LayoutRect(x: 30, y: 275, width: 150, height: 5)
    public static let courseMeterRect = LayoutRect(x: 300, y: 275, width: 150, height: 5)

    public static let ledSize = LayoutSize(width: 20, height: 20)

    public static let ledPositions: [LayoutPoint] = [
        LayoutPoint(x: 21, y: 135), LayoutPoint(x: 31, y: 127),
        LayoutPoint(x: 42, y: 119), LayoutPoint(x: 52, y: 110),
        LayoutPoint(x: 63, y: 102), LayoutPoint(x: 75, y: 94),
        LayoutPoint(x: 87, y: 87), LayoutPoint(x: 99, y: 80),
        LayoutPoint(x: 111, y: 73), LayoutPoint(x: 124, y: 68),
        LayoutPoint(x: 136, y: 63), LayoutPoint(x: 148, y: 58),
        LayoutPoint(x: 161, y: 54), LayoutPoint(x: 175, y: 50),
        LayoutPoint(x: 187, y: 46), LayoutPoint(x: 200, y: 43),
        LayoutPoint(x: 213, y: 40), LayoutPoint(x: 226, y: 38),
        LayoutPoint(x: 239, y: 36), LayoutPoint(x: 252, y: 35),
        LayoutPoint(x: 265, y: 35), LayoutPoint(x: 278, y: 36),
        LayoutPoint(x: 291, y: 36), LayoutPoint(x: 304, y: 38),
        LayoutPoint(x: 318, y: 40), LayoutPoint(x: 331, y: 43),
        LayoutPoint(x: 344, y: 47), LayoutPoint(x: 357, y: 50),
        LayoutPoint(x: 369, y: 55), LayoutPoint(x: 383, y: 59),
        LayoutPoint(x: 395, y: 63), LayoutPoint(x: 409, y: 68),
        LayoutPoint(x: 421, y: 72),
    ]
}
