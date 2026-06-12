# Changelog

All notable changes to this fork of [gouwsxander/Reef](https://github.com/gouwsxander/Reef) are documented here.

---

## [Unreleased] — Fork by KaushalKishorMishra

> Features developed with assistance from [Claude](https://claude.ai) (Anthropic).

### Added

#### Window Preview Panel
- Live window preview thumbnail in the switcher panel using ScreenCaptureKit (`SCScreenshotManager`)
- Spinner shown while thumbnail loads; falls back to action card if capture fails (e.g. permission denied or window closed)
- Panel resizes to a fixed 480×361 preview card (header + large 480×300 screenshot area)

#### App Launch from Switcher
- Pressing the shortcut for a slot whose app is not running shows a "Launch" action card
- Releasing Ctrl launches the app via `NSWorkspace.openApplication`
- Action card shows app icon, name, "Release to launch" subtitle, and a "Launch" pill badge

#### Firefox/Chromium App Support
- Apps that don't expose windows via the Accessibility API (Zen Browser, Firefox, Chrome, etc.) now fall back to `CGWindowListCopyWindowInfo` filtered by PID
- Filters: `optionOnScreenOnly`, `layer == 0`, `alpha > 0` to exclude background/utility processes

#### Screen Recording Permission Flow
- `Preferences → General` now shows a live "Window Previews" status row (always visible)
- Green checkmark when Screen Recording is granted; yellow warning + "Grant Access" button when not
- "Grant Access" calls `CGRequestScreenCaptureAccess()` which triggers the system dialog and registers the app
- Status updates immediately when app becomes active (via `NSApplication.didBecomeActiveNotification`)

#### Background Dimming
- "Switcher Panel" section in Preferences → General with a dimming slider (0–60%, step 5%)
- Stored in `@AppStorage("panelDimming")` and applied as `Color.black.opacity(panelDimming)` in the panel

#### Accessibility Permission Improvements
- "Open Settings" for Accessibility now calls `AXIsProcessTrustedWithOptions(prompt: true)` to trigger the system dialog directly
- Permission state refreshes on `.onAppear`, timer tick, and `NSApplication.didBecomeActiveNotification`

#### App Icon in Panel
- `Application.icon` computed property added — returns `NSRunningApplication.icon` for running apps, falls back to `NSWorkspace.icon(forFile:)` for non-running apps

#### Liquid Glass Design (macOS 26+)
- Window list rows use `GlassEffectContainer` + `glassEffect(.regular)` for the selected row on macOS 26+
- `glassEffectID` enables morphing animation between selections
- Clean fallback on macOS < 26 using `Color.accentColor.opacity(0.3)` selection highlight

#### CI/CD
- `.github/workflows/release.yml` — builds Release config on `v*` tag push, ad-hoc signs, zips, and creates a GitHub Release with installation instructions
- `.github/workflows/build.yml` — build check on push/PR to `main`

#### Claude Code Skill
- `.claude/commands/auto-commit.md` — project-level `/auto-commit` slash command for Claude Code

### Changed

- **Switcher panel simplified** — removed per-window list and cycling; panel now shows a single app preview
- **`CyclePanelState`** — removed `items`, `selectedIndex`, thumbnail dict; replaced with single `thumbnail: CGImage?` and `actionMode: CyclePanelAction?`
- **`CyclePanelView`** — rewritten as a single preview card (header + large thumbnail) instead of a scrollable window list
- **`CyclePanelController`** — fixed panel sizes (480×361 preview, 320×176 action); removed `cycleNext()`, `startIndex`, anchor-point resize logic
- **`ShortcutController`** — pressing the same Ctrl+number while panel is visible no longer cycles windows; pressing a different number switches app
- **`Window`** — `element` is now optional to support windows discovered via CGWindowList without an AX handle
- **README** — updated to reflect fork status, new features, updated links, and acknowledgements

### Fixed

- Action card showed "Focus app" text label instead of a proper visual card — replaced with icon + name + subtitle + pill badge
- Preview panel showed infinite spinner when app was closed — capture failure now falls back to action card
- Hidden background windows (Zen Browser, Electron apps) were counted as real windows — fixed by adding `optionOnScreenOnly` + `alpha > 0` filter to CGWindowList fallback
- Screen Recording "Open Settings" button didn't add the app to the system list — fixed by calling `CGRequestScreenCaptureAccess()` instead of just opening System Preferences URL
- Accessibility banner persisted after granting permission — fixed by adding `didBecomeActiveNotification` observer to refresh immediately on app focus

---

## Prior History

See the [upstream changelog](https://github.com/gouwsxander/Reef/releases) for changes made before this fork.
