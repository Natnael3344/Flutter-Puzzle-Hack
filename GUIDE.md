# Developer Guide

This guide explains how the puzzle actually works under the hood, how to run and play it, and what a new contributor should know before touching `lib/main.dart`. Everything below is based on reading the current source — there is no backend, API, or network call anywhere in this project (no `http`/`dio` imports, no network permissions), so there is no separate API reference document.

## Architecture at a glance

The entire app is a single file: `untitled2/lib/main.dart` (~700 lines). There is no state-management package (no Provider/Bloc/Riverpod) — everything lives in one `StatefulWidget`:

- `MyApp` — a `StatelessWidget` that just wraps `MaterialApp(home: MyHomePage())`.
- `MyHomePage` / `_MyHomePageState` — a single `State` class, mixed in with `TickerProviderStateMixin`, that owns:
  - The puzzle's tile order (`list`) and the solved reference order (`check`).
  - The move counter (`move`) and tile count (`tiles`, hardcoded to `15`).
  - A `Stopwatch` (`_stopwatch`) plus a `Timer.periodic` (`_timer`) that fires every 30ms purely to call `setState(() {})` so the on-screen stopwatch text keeps redrawing.
  - Responsive-layout flags (`isLarge`, `isMedium`, `isSmall`) recalculated on every `build()` from `MediaQuery.of(context).size.width`.
  - An `AnimationController`/`CurvedAnimation` pair used for the `SizeTransition` on the win-dialog's decorative image.

Because everything is in one class, the widget tree is built by a handful of small builder methods on `_MyHomePageState`: `header()`, `start()`, `board()`, `buildTimer()`, `shuffleButton()`, `containerText1/2/3()`, and `win()`.

## The puzzle model

The board state is a flat `List<int>` of length 16:

```dart
var list  = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0]; // current order
var check = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 0]; // solved order
```

`0` represents the blank cell. The board is rendered with `AlignedGridView.count(crossAxisCount: 4, ...)`, so index `i` maps to grid position `(row = i ~/ 4, col = i % 4)`. Tile `list[i]` is drawn from `images/<value>.png` unless the value is `0`, in which case an empty `SizedBox` is shown instead.

## Shuffling into a *solvable* state

Naively calling `list.shuffle()` on a 15-puzzle produces an unsolvable layout roughly half the time. `shuffleButton()`'s `onPressed` handler shuffles once, then repeatedly calls `shuffled()` (once per second, four times, driven by a `Timer.periodic`) until a solvable configuration is found:

```dart
void shuffled() {
  // classify the blank's row (from the bottom) as row 1 or row 2
  if (list.indexOf(0) <= 15 && list.indexOf(0) >= 12 ||
      list.indexOf(0) <= 7  && list.indexOf(0) >= 4) row = 1;
  if (list.indexOf(0) <= 11 && list.indexOf(0) >= 8 ||
      list.indexOf(0) <= 3  && list.indexOf(0) >= 0) row = 2;

  while (true) {
    // count inversions: pairs (i, j) with i < j, list[i] > list[j], neither is blank
    for (int i = 0; i < list.length - 1; i++) {
      for (int j = i + 1; j < list.length; j++) {
        if (list[i] > list[j] && list[j] != 0) count = count + 1;
      }
    }
    // classic 15-puzzle solvability rule
    if (row == 1 && count % 2 == 0 || row == 2 && count % 2 != 0) break;
    list.shuffle();
  }
}
```

This is the standard 15-puzzle parity rule: with an even-width board, a shuffle is solvable exactly when *(inversions + blank's row-from-bottom)* has a particular parity. If a shuffle fails the check, the code re-shuffles and re-counts until it passes. Note `count` is never reset before entering the `while` loop on a given call, and `row`/`count` are only reset to `0` at the top of the `shuffleButton` handler — worth keeping in mind if you refactor this.

After the 4-second shuffle sequence, `isDisable` flips to `false` (enabling tile taps) and `_stopwatch.start()` is called.

## Moving tiles

Each non-blank tile is a `MaterialButton`. Its `onPressed` (disabled while `isDisable` is `true`, i.e. before you've pressed Start) checks whether the tile at `index` is orthogonally adjacent to the blank cell, with guards so a tile in the last column doesn't "wrap" and count the first column of the next row as adjacent (and vice versa):

```dart
if (index - 1 >= 0 && list[index - 1] == 0 && index % 4 != 0 ||
    index + 1 < 16 && list[index + 1] == 0 && (index + 1) % 4 != 0 ||
    (index - 4 >= 0 && list[index - 4] == 0) ||
    (index + 4 < 16 && list[index + 4] == 0)) {
  setState(() {
    move++;
    list[list.indexOf(0)] = list[index];
    list[index] = 0;
  });
}
win();
```

`win()` is then checked after every tap.

## Win detection and the completion dialog

`win()` compares `list` to `check` with `const IterableEquality().equals(list, check)`. On a match it stops the stopwatch and opens a `showDialog` whose content is a `FutureBuilder` on an 8-second `Future.delayed`:

- While waiting (`connectionState != done`), it shows `Lottie.asset("images/balloon.json")` — the balloon celebration animation plays for those 8 seconds.
- Once the delay completes, it swaps to an `AlertDialog` showing the final time (`buildTimer`), move count, "Share Your Score!" text, and two `MaterialButton`s styled as Twitter/Facebook share buttons.

**Contributor note:** those two share buttons have empty `onPressed: () {}` callbacks — they render correctly but do not actually share anything. Wiring up real sharing (e.g. via `share_plus` or platform intents) is an open task, not a hidden feature.

Pressing **Close** resets `_stopwatch`, `isDisable`, and `move`, and pops the dialog, returning you to a fresh, disabled board (you need to press **Start**/**Restart** again to reshuffle).

## Responsive layout

`build()` recomputes three booleans from the current width every frame:

| Flag | Width range |
|---|---|
| `isLarge` | `1200 <= width < 1440` |
| `isMedium` | `576 <= width < 1200` |
| `isSmall` | `width < 576` |

`isLarge` uses a `Row` with a dedicated `start()` panel (heading, tile/move counter, Start button) beside the timer+board column. `isMedium`/`isSmall` stack everything in a single `Column` instead, and `isSmall` additionally shows a small "Simple / Dashatar" text row above the board that the other breakpoints render in the header instead. There's no explicit handling for widths ≥ 1440px — such a window still falls through as neither `isLarge`, `isMedium`, nor `isSmall`, keeping whatever flags were last set from a previous, narrower build.

## Running and playing it locally

```bash
cd untitled2
flutter pub get
flutter run            # pick a connected device, simulator, or `-d chrome` / `-d windows`
```

Once the app launches:

1. Click **Start** (top-left panel on wide windows, or inline on narrow ones).
2. Wait ~4 seconds while the app shuffles into a solvable layout — the button relabels to **Restart** once the board is playable.
3. Click tiles adjacent to the empty cell to slide them; the move counter increments per successful slide.
4. Solve the puzzle (tiles back in 1-15 order) to trigger the balloon animation, then the score dialog.
5. Click **Close** to reset and play again.

## Known rough edges (accurate as of the current `main` branch)

Worth knowing before contributing:

- **`test/widget_test.dart` is stale boilerplate.** It's the default `flutter create` counter-app smoke test (looks for a `+` icon and text `'0'`/`'1'`), not a test of the puzzle. Running `flutter test` against it will fail against this app's actual UI. A real widget/unit test suite for the puzzle logic (shuffling, adjacency, win detection) doesn't exist yet.
- **Unused dependencies** in `pubspec.yaml`: `spring_button`, `flutter_countdown_timer`, and `flutter_staggered_animations` are declared but never imported in `lib/main.dart`. Safe to remove if you're cleaning up, or a signal that some planned features (a countdown, entrance animations, spring-tap buttons) were never finished.
- **Board size is hardcoded.** `tiles = 15` is a display-only field; the actual grid size (16 slots, 4 columns) is hardcoded via literals (`16`, `4`, `index ± 4`) throughout `board()` and `shuffled()`. Changing puzzle size would require touching several places, not just one constant.
- **Project identity still says "untitled2".** The Flutter project's `name:` in `pubspec.yaml`, its folder name, its Android `applicationId` (`com.example.untitled2`), and its Android package (`com.example.untitled2`) are all unchanged `flutter create` defaults — the repo/branding name "Flutter Puzzle Hack" was never propagated into the project metadata.
- **Debug `print()` calls** remain in `shuffleButton()`'s and `win()`'s handlers (printing `row`, `count`, `list` state) — harmless, but worth removing for production code.
- **Share buttons are UI-only** (see above) — don't assume score sharing works end-to-end.

## Suggested first contributions

If you're picking this project up:

1. Replace `test/widget_test.dart` with real tests for `shuffled()`'s solvability check and the adjacency-move logic.
2. Wire up the Twitter/Facebook buttons (e.g. with `share_plus`) or remove them if out of scope.
3. Remove the three unused dependencies from `pubspec.yaml`, or actually use them (e.g. `flutter_staggered_animations` for tile-appear animations).
4. Rename the underlying Flutter project (`untitled2` → something matching "Flutter Puzzle Hack") if you want the app identity to match the repo.
