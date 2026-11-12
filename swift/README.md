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

### Manual GitHub Actions IPA

GitLab remains the authoritative remote (`origin`). The GitHub repository is the CI mirror,
and the workflow is in the root repository at `.github/workflows/ios.yml`. It is
`workflow_dispatch` only and builds just `swift/iKITT.xcodeproj`; the old Objective-C project
and the PWA do not participate. It builds an unsigned Release app for `iphoneos` on the
`xcode-27` runner, checks the built app bundle, and uploads `iKITT-unsigned-ipa` for 7 days.
Change the runner label there if this repository uses a different macOS runner.

Add the GitHub remote when ready, and push the branch you want CI to build:

```sh
git remote add github git@github.com:OWNER/iKITT.git
git push github master
```

Trigger the workflow from the GitHub Actions tab, or run this from the `swift/` directory to
trigger, wait, and download the IPA:

```sh
./build-ipa.sh
```

The helper uses the `github` remote by default; set `GITHUB_REMOTE=...` if your remote has a
different name. It triggers GitHub's default branch unless you pass extra `gh workflow run`
options such as `--ref BRANCH`, and it never pushes to either remote. The IPA is unsigned; sign
it with your usual tool before installing. Unit tests are not run in CI; use `swift test`
locally.

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
