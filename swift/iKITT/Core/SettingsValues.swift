import Foundation

public enum SettingsKey {
    public static let startupSound = "startup_sound"
    public static let sampleSet = "sample_set"
    public static let voiceboxStyle = "voicebox_style"
    public static let shuffleEnabled = "shuffle_enabled"
    public static let shuffleInterval = "shuffle_interval"
    public static let speedUnit = "speed_unit"
    public static let ledFunction = "led_function"
    public static let ledSoundEnabled = "ledsound_enabled"
}

/// Plain, testable representation of the app's persisted settings.
public struct SettingsValues: Equatable, Sendable {
    public var startupSound: StartupSoundOption
    public var sampleSet: SampleSetOption
    public var voiceboxStyle: VoiceboxStyleOption
    public var shuffleEnabled: Bool
    public var shuffleInterval: ShuffleInterval
    public var speedUnit: SpeedUnit
    public var ledFunction: LEDFunction
    public var ledSoundEnabled: Bool

    public static let standard = SettingsValues(
        startupSound: .woosh,
        sampleSet: .kitt,
        voiceboxStyle: .classic,
        shuffleEnabled: false,
        shuffleInterval: .normal,
        speedUnit: .milesPerHour,
        ledFunction: .fakeRPM,
        ledSoundEnabled: true
    )

    public init(
        startupSound: StartupSoundOption,
        sampleSet: SampleSetOption,
        voiceboxStyle: VoiceboxStyleOption,
        shuffleEnabled: Bool,
        shuffleInterval: ShuffleInterval,
        speedUnit: SpeedUnit,
        ledFunction: LEDFunction,
        ledSoundEnabled: Bool
    ) {
        self.startupSound = startupSound
        self.sampleSet = sampleSet
        self.voiceboxStyle = voiceboxStyle
        self.shuffleEnabled = shuffleEnabled
        self.shuffleInterval = shuffleInterval
        self.speedUnit = speedUnit
        self.ledFunction = ledFunction
        self.ledSoundEnabled = ledSoundEnabled
    }

    public init(defaults: UserDefaults) {
        let storedStartup = Self.integer(defaults, SettingsKey.startupSound, fallback: 0)
        let storedSampleSet = Self.integer(defaults, SettingsKey.sampleSet, fallback: 1)
        let storedVoicebox = Self.integer(defaults, SettingsKey.voiceboxStyle, fallback: 1)
        let storedShuffleInterval = Self.integer(defaults, SettingsKey.shuffleInterval, fallback: 1)
        let storedSpeedUnit = Self.integer(defaults, SettingsKey.speedUnit, fallback: 1)
        let storedLEDFunction = Self.integer(defaults, SettingsKey.ledFunction, fallback: 1)

        let sampleSet = SampleSetOption(rawValue: storedSampleSet) ?? .kitt
        let voicebox = VoiceboxStyleOption(rawValue: storedVoicebox) ?? .classic

        self.startupSound = StartupSoundOption(rawValue: storedStartup) ?? .woosh
        self.sampleSet = sampleSet.isAvailable ? sampleSet : .kitt
        self.voiceboxStyle = voicebox.isAvailable ? voicebox : .classic
        self.shuffleEnabled = Self.boolean(defaults, SettingsKey.shuffleEnabled, fallback: false)
        self.shuffleInterval = ShuffleInterval(rawValue: storedShuffleInterval) ?? .normal
        self.speedUnit = SpeedUnit(rawValue: storedSpeedUnit) ?? .milesPerHour
        self.ledFunction = LEDFunction(rawValue: storedLEDFunction) ?? .fakeRPM
        self.ledSoundEnabled = Self.boolean(defaults, SettingsKey.ledSoundEnabled, fallback: true)
    }

    public func write(to defaults: UserDefaults) {
        defaults.set(startupSound.rawValue, forKey: SettingsKey.startupSound)
        defaults.set(sampleSet.rawValue, forKey: SettingsKey.sampleSet)
        defaults.set(voiceboxStyle.rawValue, forKey: SettingsKey.voiceboxStyle)
        defaults.set(shuffleEnabled, forKey: SettingsKey.shuffleEnabled)
        defaults.set(shuffleInterval.rawValue, forKey: SettingsKey.shuffleInterval)
        defaults.set(speedUnit.rawValue, forKey: SettingsKey.speedUnit)
        defaults.set(ledFunction.rawValue, forKey: SettingsKey.ledFunction)
        defaults.set(ledSoundEnabled, forKey: SettingsKey.ledSoundEnabled)
    }

    private static func integer(_ defaults: UserDefaults, _ key: String, fallback: Int) -> Int {
        if let number = defaults.object(forKey: key) as? NSNumber {
            return number.intValue
        }
        if let string = defaults.object(forKey: key) as? String, let value = Int(string) {
            return value
        }
        return fallback
    }

    private static func boolean(_ defaults: UserDefaults, _ key: String, fallback: Bool) -> Bool {
        if let number = defaults.object(forKey: key) as? NSNumber {
            return number.boolValue
        }
        if let string = defaults.object(forKey: key) as? String {
            switch string.lowercased() {
            case "1", "true", "yes": return true
            case "0", "false", "no": return false
            default: break
            }
        }
        return fallback
    }
}
