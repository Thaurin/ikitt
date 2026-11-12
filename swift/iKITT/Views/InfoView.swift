import Foundation
import SwiftUI

struct InfoView: View {
    let onDismiss: () -> Void
    @Environment(\.openURL) private var openURL

    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.2"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Text("iKITT")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(Color.white)

                    Text("Version \(version)")
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)

                    Text("A shadowy flight into the world of a man who does not exist...")
                        .font(.body)

                    Text("Programming: Ivo van Heel\nGraphics: Marcel van Beek")
                        .font(.callout)
                        .foregroundStyle(Color.secondary)

                    VStack(spacing: 14) {
                        Text("Instructions")
                            .font(.headline)

                        Text(
                            """
                            Tap the buttons on the left and right side to make KITT speak! \
                            Select one of the three buttons in the middle to select a page. \
                            Single tap on the voice box to play a random sound. Double tap \
                            the voice box to zoom it in or out. Shake for Turbo Boost! Use \
                            the gear in the lower-left corner for settings.
                            """
                        )

                        Text("Dashboard")
                            .font(.headline)
                            .padding(.top, 4)

                        Text(
                            """
                            Turn the device to landscape for the dashboard. Double tap on \
                            the speedometer to zoom it in or out. Tap the unit to switch \
                            between the metric and imperial system.
                            """
                        )
                    }

                    Text("That's it! Have fun!\nThanatist Software")
                        .font(.callout)
                        .foregroundStyle(Color.secondary)

                    Button {
                        if let url = URL(string: "https://www.mentation.nl/thanatist/") {
                            openURL(url)
                        }
                    } label: {
                        Text("Go to website")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .buttonStyle(RetroButtonStyle())
                    .padding(.top, 6)
                }
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 26)
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
                .textSelection(.enabled)
            }
            .background(Color.black)
            .navigationTitle("iKITT")
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
        }
        .preferredColorScheme(.dark)
        .background(Color.black.ignoresSafeArea())
    }
}

struct RetroButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.white)
            .padding(.horizontal, 22)
            .frame(height: 44)
            .background {
                Image(configuration.isPressed ? "blueButton" : "grayButton")
                    .resizable(
                        capInsets: EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12),
                        resizingMode: .stretch
                    )
            }
            .contentShape(Rectangle())
            .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
    }
}
