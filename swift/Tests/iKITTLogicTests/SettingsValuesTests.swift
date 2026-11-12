import XCTest

@testable import iKITTLogic

final class SettingsValuesTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "iKITT.SettingsTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testDefaultValuesUseIncludedOptions() {
        let values = SettingsValues(defaults: defaults)

        XCTAssertEqual(values.startupSound, .woosh)
        XCTAssertEqual(values.sampleSet, .kitt)
        XCTAssertEqual(values.voiceboxStyle, .classic)
        XCTAssertFalse(values.shuffleEnabled)
        XCTAssertEqual(values.shuffleInterval, .normal)
        XCTAssertEqual(values.speedUnit, .milesPerHour)
        XCTAssertEqual(values.ledFunction, .fakeRPM)
        XCTAssertTrue(values.ledSoundEnabled)
    }

    func testValuesRoundTripThroughUserDefaults() {
        var values = SettingsValues.standard
        values.startupSound = .beeps
        values.sampleSet = .kitt
        values.voiceboxStyle = .classic
        values.shuffleEnabled = true
        values.shuffleInterval = .slow
        values.speedUnit = .kilometersPerHour
        values.ledFunction = .speed
        values.ledSoundEnabled = false
        values.write(to: defaults)

        let loaded = SettingsValues(defaults: defaults)
        XCTAssertEqual(loaded, values)
    }

    func testLegacyStringValuesAreRead() {
        defaults.set("1", forKey: SettingsKey.startupSound)
        defaults.set("0", forKey: SettingsKey.sampleSet)
        defaults.set("1", forKey: SettingsKey.voiceboxStyle)
        defaults.set("1", forKey: SettingsKey.shuffleEnabled)
        defaults.set("3", forKey: SettingsKey.shuffleInterval)
        defaults.set("0", forKey: SettingsKey.speedUnit)
        defaults.set("0", forKey: SettingsKey.ledFunction)
        defaults.set("0", forKey: SettingsKey.ledSoundEnabled)

        let values = SettingsValues(defaults: defaults)
        XCTAssertEqual(values.startupSound, .beeps)
        XCTAssertEqual(values.sampleSet, .kitt)
        XCTAssertEqual(values.voiceboxStyle, .classic)
        XCTAssertTrue(values.shuffleEnabled)
        XCTAssertEqual(values.shuffleInterval, .slow)
        XCTAssertEqual(values.speedUnit, .kilometersPerHour)
        XCTAssertEqual(values.ledFunction, .speed)
        XCTAssertFalse(values.ledSoundEnabled)
    }

    func testUnavailableLegacyChoicesFallBackToIncludedAssets() {
        defaults.set(1, forKey: SettingsKey.sampleSet)
        defaults.set(2, forKey: SettingsKey.voiceboxStyle)

        let values = SettingsValues(defaults: defaults)
        XCTAssertEqual(values.sampleSet, .kitt)
        XCTAssertEqual(values.voiceboxStyle, .classic)
    }

    func testOutOfRangeValuesFallBack() {
        defaults.set(99, forKey: SettingsKey.speedUnit)
        defaults.set(-4, forKey: SettingsKey.ledFunction)

        let values = SettingsValues(defaults: defaults)
        XCTAssertEqual(values.speedUnit, .milesPerHour)
        XCTAssertEqual(values.ledFunction, .fakeRPM)
    }
}
