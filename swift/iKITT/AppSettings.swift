import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    @ObservationIgnored private let defaults: UserDefaults
    private var values: SettingsValues

    var startupSound: StartupSoundOption {
        get { values.startupSound }
        set {
            values.startupSound = newValue
            persist()
        }
    }

    var sampleSet: SampleSetOption {
        get { values.sampleSet }
        set {
            values.sampleSet = newValue
            persist()
        }
    }

    var voiceboxStyle: VoiceboxStyleOption {
        get { values.voiceboxStyle }
        set {
            values.voiceboxStyle = newValue
            persist()
        }
    }

    var shuffleEnabled: Bool {
        get { values.shuffleEnabled }
        set {
            values.shuffleEnabled = newValue
            persist()
        }
    }

    var shuffleInterval: ShuffleInterval {
        get { values.shuffleInterval }
        set {
            values.shuffleInterval = newValue
            persist()
        }
    }

    var speedUnit: SpeedUnit {
        get { values.speedUnit }
        set {
            values.speedUnit = newValue
            persist()
        }
    }

    var ledFunction: LEDFunction {
        get { values.ledFunction }
        set {
            values.ledFunction = newValue
            persist()
        }
    }

    var ledSoundEnabled: Bool {
        get { values.ledSoundEnabled }
        set {
            values.ledSoundEnabled = newValue
            persist()
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.values = SettingsValues(defaults: defaults)
    }

    private func persist() {
        values.write(to: defaults)
    }
}
