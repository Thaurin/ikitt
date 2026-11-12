import AVFoundation
import Foundation

/// Synthesises a short dashboard tick. The original click sample is not present
/// in the archive, so the modern port recreates the effect in memory.
@MainActor
final class ClickPlayer {
    private var player: AVAudioPlayer?
    private var lastPlayed = Date.distantPast
    private let minimumInterval: TimeInterval = 0.09

    func play() {
        let now = Date()
        guard now.timeIntervalSince(lastPlayed) >= minimumInterval else { return }
        lastPlayed = now

        if player == nil {
            player = try? AVAudioPlayer(data: Self.clickData, fileTypeHint: AVFileType.wav.rawValue)
            _ = player?.prepareToPlay()
        }

        player?.volume = 0.18
        player?.currentTime = 0
        _ = player?.play()
    }

    private static let clickData: Data = makeClickData()

    private static func makeClickData() -> Data {
        let sampleRate = 44_100
        let sampleCount = Int(Double(sampleRate) * 0.012)
        let dataSize = UInt32(sampleCount * MemoryLayout<Int16>.size)

        var data = Data()
        data.append(contentsOf: Array("RIFF".utf8))
        append(36 + dataSize, to: &data)
        data.append(contentsOf: Array("WAVE".utf8))
        data.append(contentsOf: Array("fmt ".utf8))
        append(UInt32(16), to: &data)
        append(UInt16(1), to: &data)
        append(UInt16(1), to: &data)
        append(UInt32(sampleRate), to: &data)
        append(UInt32(sampleRate * 2), to: &data)
        append(UInt16(2), to: &data)
        append(UInt16(16), to: &data)
        data.append(contentsOf: Array("data".utf8))
        append(dataSize, to: &data)

        for index in 0..<sampleCount {
            let time = Double(index) / Double(sampleRate)
            let envelope = exp(-time * 260)
            let tone = sin(2 * Double.pi * 1_900 * time)
            let value = max(-1, min(1, tone * envelope * 0.35))
            append(Int16(value * Double(Int16.max)), to: &data)
        }

        return data
    }

    private static func append<T: FixedWidthInteger>(_ value: T, to data: inout Data) {
        var littleEndian = value.littleEndian
        withUnsafeBytes(of: &littleEndian) { bytes in
            data.append(contentsOf: bytes)
        }
    }
}
