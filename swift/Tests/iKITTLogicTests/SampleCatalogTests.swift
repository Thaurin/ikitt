import XCTest

@testable import iKITTLogic

final class SampleCatalogTests: XCTestCase {
    func testCatalogContainsAllTwentyFourSamples() {
        XCTAssertEqual(SampleCatalog.all.count, 24)
        XCTAssertEqual(Set(SampleCatalog.all).count, 24)
        XCTAssertEqual(SampleCatalog.all.first, KittSample(page: 1, tag: 1))
        XCTAssertEqual(SampleCatalog.all.last, KittSample(page: 3, tag: 8))
    }

    func testResourceNamesAndValidation() {
        XCTAssertEqual(KittSample(page: 2, tag: 7).resourceName, "kitt2-7")
        XCTAssertTrue(SampleCatalog.isValid(page: 1, tag: 1))
        XCTAssertTrue(SampleCatalog.isValid(page: 3, tag: 8))
        XCTAssertFalse(SampleCatalog.isValid(page: 0, tag: 1))
        XCTAssertFalse(SampleCatalog.isValid(page: 4, tag: 1))
        XCTAssertFalse(SampleCatalog.isValid(page: 1, tag: 9))
    }

    func testRandomNeverRepeatsThePreviousSample() {
        var generator = SeededGenerator(seed: 42)
        var previous: KittSample?

        for _ in 0..<1_000 {
            let sample = SampleCatalog.random(excluding: previous, using: &generator)
            XCTAssertNotEqual(sample, previous)
            XCTAssertTrue(SampleCatalog.all.contains(sample))
            previous = sample
        }
    }

    func testRandomWithoutPreviousStillReturnsCatalogSamples() {
        var generator = SeededGenerator(seed: 7)
        for _ in 0..<100 {
            let sample = SampleCatalog.random(excluding: nil, using: &generator)
            XCTAssertTrue(SampleCatalog.all.contains(sample))
        }
    }
}
