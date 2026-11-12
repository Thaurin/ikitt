import Foundation

public struct KittSample: Hashable, Sendable {
    public let page: Int
    public let tag: Int

    public init(page: Int, tag: Int) {
        self.page = page
        self.tag = tag
    }

    public var resourceName: String {
        "kitt\(page)-\(tag)"
    }
}

public enum SampleCatalog {
    public static let pageCount = 3
    public static let tagsPerPage = 8

    public static let all: [KittSample] = (1...pageCount).flatMap { page in
        (1...tagsPerPage).map { KittSample(page: page, tag: $0) }
    }

    public static func isValid(page: Int, tag: Int) -> Bool {
        (1...pageCount).contains(page) && (1...tagsPerPage).contains(tag)
    }

    /// Chooses a random sample, avoiding the exact sample that just played.
    public static func random(
        excluding previous: KittSample?,
        using generator: inout some RandomNumberGenerator
    ) -> KittSample {
        let candidates = all.filter { $0 != previous }
        return candidates.randomElement(using: &generator) ?? all[0]
    }
}

public enum SoundEffect: String, Sendable {
    case startup
    case turboBoost = "turboboost"
    case beep1
    case beep2
    case beep3
}
