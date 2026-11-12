import AVFoundation
import Observation

@MainActor
@Observable
final class AudioService: NSObject, @preconcurrency AVAudioPlayerDelegate {
    @ObservationIgnored private var player: AVAudioPlayer?
    @ObservationIgnored private var meterTask: Task<Void, Never>?
    @ObservationIgnored private var completion: (@MainActor () -> Void)?

    var voiceboxFrameIndex = 0
    var isPlaying = false

    override init() {
        super.init()
        configureAudioSession()
    }

    func play(
        resource: String,
        metering: Bool,
        completion: @MainActor @escaping () -> Void
    ) {
        stop()

        guard let url = Self.url(for: resource) else {
            completion()
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.isMeteringEnabled = metering
            _ = player.prepareToPlay()

            self.player = player
            self.completion = completion
            isPlaying = true

            try? AVAudioSession.sharedInstance().setActive(true)
            guard player.play() else {
                finishPlayback()
                return
            }

            if metering {
                startMetering()
            }
        } catch {
            completion()
        }
    }

    func stop() {
        meterTask?.cancel()
        meterTask = nil
        player?.stop()
        player = nil
        completion = nil
        isPlaying = false
        voiceboxFrameIndex = 0
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    private func startMetering() {
        meterTask?.cancel()
        meterTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                guard let self, let player = self.player, player.isPlaying else { break }
                player.updateMeters()
                let index = Self.frameIndex(for: player.averagePower(forChannel: 0))
                if voiceboxFrameIndex != index {
                    voiceboxFrameIndex = index
                }
                try? await Task.sleep(for: .milliseconds(10))
            }
        }
    }

    private func finishPlayback() {
        meterTask?.cancel()
        meterTask = nil
        player = nil
        isPlaying = false
        voiceboxFrameIndex = 0

        let completion = completion
        self.completion = nil
        completion?()
    }

    private static func frameIndex(for averagePower: Float) -> Int {
        var power = Int(averagePower) + 160
        power = max(140, power) - 140
        return min(6, max(0, (7 * power) / 20))
    }

    private static func url(for resource: String) -> URL? {
        Bundle.main.url(forResource: resource, withExtension: "wav", subdirectory: "Audio")
            ?? Bundle.main.url(forResource: resource, withExtension: "wav")
    }

    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let identifier = ObjectIdentifier(player)
        Task { @MainActor [weak self] in
            guard let self, let current = self.player,
                ObjectIdentifier(current) == identifier
            else { return }
            self.finishPlayback()
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: (any Error)?) {
        let identifier = ObjectIdentifier(player)
        Task { @MainActor [weak self] in
            guard let self, let current = self.player,
                ObjectIdentifier(current) == identifier
            else { return }
            self.finishPlayback()
        }
    }
}
