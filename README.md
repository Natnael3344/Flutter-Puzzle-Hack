# Flutter Puzzle Hack

A classic 15-tile sliding picture puzzle ("15-puzzle") built with Flutter, styled after the blue "Simple / Dashatar" look of Flutter's official Puzzle Hack sample app. Fifteen numbered image tiles sit on a 4x4 board with one empty slot; you slide tiles into the empty slot to restore the original 1-15 order while a stopwatch and move counter track your performance, and a celebratory Lottie animation plays when you solve it.

## What it plays like

1. You land on a single screen showing the Flutter logo, a "Puzzle Challenge" heading, a move/tile counter, a stopwatch, and a **Start** button.
2. Pressing **Start** shuffles the 16 tiles (15 numbered tiles + 1 blank) for a few seconds, guaranteeing the resulting layout is actually solvable, then unlocks the board and starts the stopwatch.
3. Tap any tile that is directly above, below, left, or right of the blank space to slide it into the gap. Each successful slide increments the move counter.
4. When the tiles return to numeric order (1-15, blank last), the stopwatch stops and a completion dialog appears — first an animated balloon (via a Lottie animation), then an "AlertDialog" showing your time and move count with (non-functional, UI-only) Twitter/Facebook "share your score" buttons.
5. Closing the dialog resets the timer and move counter so you can press **Start**/**Restart** again.

The layout is responsive: it switches between a two-column ("large" desktop, ≥1200px) arrangement and stacked single-column ("medium"/"small") arrangements depending on screen width.

## Verified features

- 4x4 (15-tile) sliding puzzle with a single blank cell, rendered with `AlignedGridView` from `flutter_staggered_grid_view`.
- **Guaranteed-solvable shuffles**: after each random `list.shuffle()`, the app counts tile inversions and checks blank-row parity, re-shuffling in a loop until the classic 15-puzzle solvability rule is satisfied.
- **Adjacency-based move logic**: a tile can only move into the blank cell if it is directly up, down, left, or right of it (with row-wrap guards so tiles don't "jump" across rows).
- **Move counter and live stopwatch** (updated on a 30ms `Timer.periodic` tick) formatted as `HH:MM:SS`.
- **Win detection** via `IterableEquality` comparing the live tile order to the solved order, which stops the stopwatch and opens the completion dialog.
- **Completion dialog** with a Lottie balloon animation (`images/balloon.json`), a score summary (time + moves), and Twitter/Facebook buttons in the UI (their `onPressed` handlers are empty — no real sharing is wired up).
- **Responsive breakpoints**: small (<576px), medium (576-1199px), and large (1200-1439px) window widths each get a tailored layout.
- Numbered tile artwork (`images/1.png` … `images/15.png`), a blue background illustration, and the Flutter mascot logo, all bundled under `images/`.

## Tech stack

- **Flutter / Dart** — `environment: sdk: ">=2.16.1 <3.0.0"` in `pubspec.yaml` (a Flutter 2.x-era SDK constraint).
- Packages actually used in `lib/main.dart`:
  - [`flutter_staggered_grid_view`](https://pub.dev/packages/flutter_staggered_grid_view) — `AlignedGridView` for the puzzle board.
  - [`collection`](https://pub.dev/packages/collection) — `IterableEquality` for win-state comparison.
  - [`lottie`](https://pub.dev/packages/lottie) — the balloon celebration animation.
  - `cupertino_icons` — bundled per Flutter template default.
- Declared in `pubspec.yaml` but **not currently imported/used** anywhere in the code: `spring_button`, `flutter_countdown_timer`, `flutter_staggered_animations`.
- `flutter_lints` (dev dependency) for static analysis, configured in `analysis_options.yaml`.

## Project structure

The actual Flutter project lives inside the `untitled2/` subdirectory of this repo (that's also its internal Flutter package name — see the note in [`GUIDE.md`](GUIDE.md)):

```
Flutter-Puzzle-Hack/
└── untitled2/
    ├── lib/
    │   └── main.dart          # The entire app: UI, state, puzzle & win logic
    ├── test/
    │   └── widget_test.dart   # Default Flutter counter-app template (see GUIDE.md)
    ├── images/                # Tile artwork (1.png-15.png), background, logo, Lottie file
    ├── android/                # Android platform project
    ├── ios/                    # iOS platform project
    ├── web/                    # Web platform project
    ├── windows/                 # Windows platform project
    ├── pubspec.yaml            # Dependencies & asset declarations
    └── analysis_options.yaml   # Lint configuration
```

## Getting started

Requirements: a working [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and on your `PATH`.

```bash
git clone https://github.com/Natnael3344/Flutter-Puzzle-Hack.git
cd Flutter-Puzzle-Hack/untitled2

# install dependencies
flutter pub get

# run on a connected device/emulator, or a desktop/web target
flutter run
```

Platform folders for Android, iOS, Web, and Windows are all present, so `flutter run -d chrome`, `flutter run -d windows`, or running on an emulator/simulator should all work out of the box (not all targets have been exhaustively verified by the project's own CI, since none currently exists).

For a deeper look at how the puzzle logic and state management actually work, see [`GUIDE.md`](GUIDE.md).

---
*Comment in the source (`lib/main.dart`): "Created By:- Natnael Tamirat".*
