import SwiftUI

struct SettingsView: View {
    let settings: AppSettings
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        OptionSelectionView(
                            title: "Start-up sound",
                            options: Array(StartupSoundOption.allCases),
                            selection: Binding(
                                get: { settings.startupSound },
                                set: { settings.startupSound = $0 }
                            )
                        )
                    } label: {
                        SettingsRow(title: "Start-up sound", value: settings.startupSound.title)
                    }

                    NavigationLink {
                        OptionSelectionView(
                            title: "Sample set",
                            options: Array(SampleSetOption.allCases),
                            selection: Binding(
                                get: { settings.sampleSet },
                                set: { settings.sampleSet = $0 }
                            )
                        )
                    } label: {
                        SettingsRow(title: "Sample set", value: settings.sampleSet.title)
                    }

                    NavigationLink {
                        OptionSelectionView(
                            title: "Voicebox style",
                            options: Array(VoiceboxStyleOption.allCases),
                            selection: Binding(
                                get: { settings.voiceboxStyle },
                                set: { settings.voiceboxStyle = $0 }
                            )
                        )
                    } label: {
                        SettingsRow(title: "Voicebox style", value: settings.voiceboxStyle.title)
                    }
                } header: {
                    Text("General")
                } footer: {
                    Text("This build includes the KITT sample set and the classic 2nd-4th season voicebox.")
                }

                Section("Shuffle") {
                    Toggle(
                        "Shuffle",
                        isOn: Binding(
                            get: { settings.shuffleEnabled },
                            set: { settings.shuffleEnabled = $0 }
                        )
                    )

                    NavigationLink {
                        OptionSelectionView(
                            title: "Shuffle interval",
                            options: Array(ShuffleInterval.allCases),
                            selection: Binding(
                                get: { settings.shuffleInterval },
                                set: { settings.shuffleInterval = $0 }
                            )
                        )
                    } label: {
                        SettingsRow(title: "Shuffle interval", value: settings.shuffleInterval.title)
                    }
                }

                Section("Dashboard") {
                    NavigationLink {
                        OptionSelectionView(
                            title: "Speed unit",
                            options: Array(SpeedUnit.allCases),
                            selection: Binding(
                                get: { settings.speedUnit },
                                set: { settings.speedUnit = $0 }
                            )
                        )
                    } label: {
                        SettingsRow(title: "Speed unit", value: settings.speedUnit.title)
                    }

                    NavigationLink {
                        OptionSelectionView(
                            title: "LED function",
                            options: Array(LEDFunction.allCases),
                            selection: Binding(
                                get: { settings.ledFunction },
                                set: { settings.ledFunction = $0 }
                            )
                        )
                    } label: {
                        SettingsRow(title: "LED function", value: settings.ledFunction.title)
                    }

                    Toggle(
                        "LED sound",
                        isOn: Binding(
                            get: { settings.ledSoundEnabled },
                            set: { settings.ledSoundEnabled = $0 }
                        )
                    )
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Label("Back", systemImage: "chevron.left")
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .tint(.orange)
        }
        .preferredColorScheme(.dark)
        .background(Color.black.ignoresSafeArea())
    }
}

private struct SettingsRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(Color.secondary)
        }
    }
}

private struct OptionSelectionView<Option: SettingsChoice>: View {
    let title: String
    let options: [Option]
    @Binding var selection: Option

    var body: some View {
        List {
            ForEach(options) { option in
                Button {
                    if option.isAvailable {
                        selection = option
                    }
                } label: {
                    HStack {
                        Text(option.title)
                            .foregroundStyle(option.isAvailable ? Color.primary : Color.secondary)

                        Spacer()

                        if selection == option {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.orange)
                        } else if !option.isAvailable {
                            Text("Unavailable")
                                .font(.caption)
                                .foregroundStyle(Color.secondary.opacity(0.6))
                        }
                    }
                    .contentShape(Rectangle())
                }
                .disabled(!option.isAvailable)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .background(Color.black)
        .tint(.orange)
    }
}
