import Foundation

/// A choice that can be shown in the settings selection screen.
public protocol SettingsChoice: CaseIterable, Identifiable, Hashable {
    var title: String { get }
    var isAvailable: Bool { get }
}

extension SettingsChoice {
    public var isAvailable: Bool { true }
}

public enum StartupSoundOption: Int, CaseIterable, Identifiable, Sendable, SettingsChoice {
    case woosh = 0
    case beeps = 1

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .woosh: "Woosh"
        case .beeps: "Beeps"
        }
    }
}

public enum SampleSetOption: Int, CaseIterable, Identifiable, Sendable, SettingsChoice {
    case kitt = 0
    case karr = 1
    case spanish = 2

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .kitt: "KITT"
        case .karr: "KARR"
        case .spanish: "Spanish"
        }
    }

    /// Only the KITT sample set was included in the original archive.
    public var isAvailable: Bool { self == .kitt }
}

public enum VoiceboxStyleOption: Int, CaseIterable, Identifiable, Sendable, SettingsChoice {
    case firstSeason = 0
    case classic = 1
    case karr = 2

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .firstSeason: "1st season"
        case .classic: "2nd-4th season"
        case .karr: "KARR"
        }
    }

    /// Only one voicebox animation set was included in the original archive.
    public var isAvailable: Bool { self == .classic }
}

public enum SpeedUnit: Int, CaseIterable, Identifiable, Sendable, SettingsChoice {
    case kilometersPerHour = 0
    case milesPerHour = 1

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .kilometersPerHour: "km/h"
        case .milesPerHour: "mph"
        }
    }

    /// The multiplier used to convert metres per second into the displayed unit.
    public var metersPerSecondMultiplier: Double {
        switch self {
        case .kilometersPerHour: 3.6
        case .milesPerHour: 2.23693629
        }
    }

    public var toggled: SpeedUnit {
        self == .kilometersPerHour ? .milesPerHour : .kilometersPerHour
    }
}

public enum LEDFunction: Int, CaseIterable, Identifiable, Sendable, SettingsChoice {
    case speed = 0
    case fakeRPM = 1

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .speed: "Speed"
        case .fakeRPM: "Fake RPM"
        }
    }
}

public enum ShuffleInterval: Int, CaseIterable, Identifiable, Sendable, SettingsChoice {
    case fast = 0
    case normal = 1
    case relaxed = 2
    case slow = 3

    public var id: Int { rawValue }

    public var title: String {
        switch self {
        case .fast: "3-7 sec"
        case .normal: "7-15 sec"
        case .relaxed: "10-25 sec"
        case .slow: "30-60 sec"
        }
    }

    public var range: ClosedRange<Double> {
        switch self {
        case .fast: 3...7
        case .normal: 7...15
        case .relaxed: 10...25
        case .slow: 30...60
        }
    }
}
