import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    enum Panel: Equatable {
        case none
        case info
        case settings
    }

    let settings: AppSettings
    let audio: AudioService
    let motion: MotionService
    let clickPlayer: ClickPlayer
    let dashboard: DashboardModel

    var selectedPage = 1
    var litButtonTag: Int?
    var lastSample: KittSample?
    var revealedRows: Set<Int> = []
    var showsLogo = false
    var controlsVisible = false
    var introPlayed = false
    var voiceboxZoomed = false
    var activePanel: Panel = .none
    private(set) var isPortraitActive = false

    @ObservationIgnored private var introTask: Task<Void, Never>?
    @ObservationIgnored private var startupTask: Task<Void, Never>?
    @ObservationIgnored private var shuffleTask: Task<Void, Never>?

    init() {
        let settings = AppSettings()
        let audio = AudioService()
        let motion = MotionService()
        let dashboard = DashboardModel()

        self.settings = settings
        self.audio = audio
        self.motion = motion
        self.clickPlayer = ClickPlayer()
        self.dashboard = dashboard

        motion.onShake = { [weak self] in
            self?.handleShake()
        }
    }

    func setPortrait(_ isPortrait: Bool) {
        guard isPortraitActive != isPortrait else { return }
        isPortraitActive = isPortrait

        if isPortrait {
            motion.start()
            if !introPlayed {
                startIntro()
            }
            reconcileShuffle()
        } else {
            motion.stop()
            voiceboxZoomed = false
            activePanel = .none
            reconcileShuffle()
        }
    }

    func setAppActive(_ isActive: Bool) {
        if isActive {
            if introPlayed, !controlsVisible {
                revealedRows = Set(0..<4)
                showsLogo = true
                controlsVisible = true
            }
            if isPortraitActive {
                motion.start()
                reconcileShuffle()
            }
        } else {
            startupTask?.cancel()
            startupTask = nil
            stopAudio()
            shuffleTask?.cancel()
            shuffleTask = nil
            motion.stop()
        }
    }

    func settingsDidChange() {
        reconcileShuffle()
    }

    func selectPage(_ page: Int) {
        guard controlsVisible, (1...SampleCatalog.pageCount).contains(page) else { return }
        selectedPage = page
        litButtonTag = nil
        audio.play(resource: "beep\(page)", metering: false) { [weak self] in
            self?.playbackFinished()
        }
    }

    func pressSideButton(tag: Int) {
        guard controlsVisible, SampleCatalog.isValid(page: selectedPage, tag: tag) else { return }
        let sample = KittSample(page: selectedPage, tag: tag)

        if audio.isPlaying, lastSample == sample {
            audio.stop()
            litButtonTag = nil
            return
        }

        play(sample: sample)
    }

    func playRandom() {
        guard controlsVisible, activePanel == .none else { return }
        var generator = SystemRandomNumberGenerator()
        let sample = SampleCatalog.random(excluding: lastSample, using: &generator)
        play(sample: sample)
    }

    func toggleVoiceboxZoom() {
        guard controlsVisible, activePanel == .none else { return }
        voiceboxZoomed.toggle()
    }

    func openPanel(_ panel: Panel) {
        guard controlsVisible, isPortraitActive, panel != .none else { return }
        stopAudio()
        voiceboxZoomed = false
        activePanel = panel
        reconcileShuffle()
    }

    func closePanel() {
        guard activePanel != .none else { return }
        activePanel = .none
        if isPortraitActive {
            motion.start()
            reconcileShuffle()
        }
    }

    private func play(sample: KittSample) {
        litButtonTag = sample.tag
        lastSample = sample
        audio.play(resource: sample.resourceName, metering: true) { [weak self] in
            self?.playbackFinished()
        }
    }

    private func playbackFinished() {
        litButtonTag = nil
    }

    private func stopAudio() {
        audio.stop()
        litButtonTag = nil
    }

    private func handleShake() {
        guard isPortraitActive, activePanel == .none else { return }
        litButtonTag = nil
        audio.play(resource: SoundEffect.turboBoost.rawValue, metering: false) { [weak self] in
            self?.playbackFinished()
        }
    }

    private func startIntro() {
        guard !introPlayed else { return }
        introPlayed = true
        revealedRows = []
        showsLogo = false
        controlsVisible = false

        playStartupSound()

        introTask?.cancel()
        introTask = Task { @MainActor [weak self] in
            guard let self else { return }

            for row in 0..<4 {
                self.revealedRows.insert(row)
                try? await Task.sleep(for: .milliseconds(100))
                guard !Task.isCancelled else { return }
            }

            self.showsLogo = true
            try? await Task.sleep(for: .milliseconds(750))
            guard !Task.isCancelled else { return }

            self.controlsVisible = true
            self.reconcileShuffle()
        }
    }

    private func playStartupSound() {
        startupTask?.cancel()

        switch settings.startupSound {
        case .woosh:
            audio.play(resource: SoundEffect.startup.rawValue, metering: false) { [weak self] in
                self?.playbackFinished()
            }
        case .beeps:
            audio.play(resource: SoundEffect.beep1.rawValue, metering: false) { [weak self] in
                self?.playbackFinished()
            }

            startupTask = Task { @MainActor [weak self] in
                guard let self else { return }
                try? await Task.sleep(for: .milliseconds(180))
                guard !Task.isCancelled else { return }
                self.audio.play(resource: SoundEffect.beep2.rawValue, metering: false) { [weak self] in
                    self?.playbackFinished()
                }
                try? await Task.sleep(for: .milliseconds(180))
                guard !Task.isCancelled else { return }
                self.audio.play(resource: SoundEffect.beep3.rawValue, metering: false) { [weak self] in
                    self?.playbackFinished()
                }
            }
        }
    }

    private func reconcileShuffle() {
        shuffleTask?.cancel()
        shuffleTask = nil

        guard settings.shuffleEnabled,
            introPlayed,
            isPortraitActive,
            activePanel == .none
        else {
            return
        }

        shuffleTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                var generator = SystemRandomNumberGenerator()
                let delay = ShuffleSchedule.delay(for: self.settings.shuffleInterval, using: &generator)
                try? await Task.sleep(for: .seconds(delay))
                guard !Task.isCancelled else { return }

                if !self.audio.isPlaying {
                    self.playRandom()
                }
            }
        }
    }
}
