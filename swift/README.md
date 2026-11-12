# iKITT — SwiftUI

A native SwiftUI rewrite of the 2010 iPhone KITT soundboard, targeting iOS 27 and iPhone.

The original artwork and 29 WAV samples are reused unchanged. The app keeps the original
interaction model while adapting the layout to modern screens and safe areas:

- Portrait: animated KITT voicebox, eight side buttons, three page buttons, startup intro,
  random sample on voicebox tap, double-tap zoom, shake for Turbo Boost, info and settings.
- Landscape: GPS speedometer with smooth speed interpolation, 33-LED arc, signal/vertical
  accuracy, altitude and course meters, metric/imperial toggle, and double-tap zoom.
- Settings: persisted with `UserDefaults` using the original key names. Shuffle, speed unit,
  LED function and LED sound are applied live.

## Build

Open `iKITT.xcodeproj` with Xcode 27 (iOS 27 SDK), select an iPhone simulator or device, and run.
The app has no external package dependencies. For a physical device, select your development
team in Signing & Capabilities; the simulator needs no signing setup.

Location and motion usage descriptions are generated from build settings. Status bar and home
indicator are hidden while the console is active. The idle timer is disabled only on the
landscape dashboard.

## Verify the shared logic

The small Foundation-only model layer can be built and tested without Xcode:

```sh
cd swift
swift test
```

The tests cover settings persistence/migration, sample selection, LED and speed math, shuffle
timing, and the original layout geometry.

## Archive notes

- Only the KITT sample set and the classic (2nd-4th season) voicebox were present in the original
  repository. KARR/Spanish sample sets and alternate voiceboxes remain visible in settings but are
  marked unavailable.
- The original LED click sample is missing, so the Swift port synthesises a short tick in memory.
- The app icon is a high-resolution recreation of the original scanner icon.
- The original Xcode/Objective-C project is left untouched at the repository root.
