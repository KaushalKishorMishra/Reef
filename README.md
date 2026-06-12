# Reef

The macOS window manager that gives every app its own Alt-Tab. 

![Cover photo. Reef logo and UI.](./github-assets/reef-banner-1280-short.jpg)

> **Fork notice:** This is a fork of [gouwsxander/Reef](https://github.com/gouwsxander/Reef) by Xander Gouws. Original project and concept by Xander Gouws. New features in this fork were developed by Kaushal Kishor Mishra with assistance from [Claude](https://claude.ai) (Anthropic's AI assistant).

See [GitHub Releases](https://github.com/KaushalKishorMishra/Reef/releases/latest) (Requires macOS 14.6+)


## Key Features

Reef lets you bind applications to number keys and cycle through their windows with an Alt-Tab-like interface.

We built Reef because we wanted a fast and simple window switcher for macOS.

- Bind applications to number keys to refocus to **any** window for that app
- Assign profiles for different sets of bindings
- Do your binding and profile management through the keyboard
- Customizable keyboard shortcuts


## What's New in This Fork

- **Window previews** — the switcher panel shows a live screenshot of the app's current window (requires Screen Recording permission)
- **App launch support** — pressing the shortcut for a closed app shows a launch card; releasing Ctrl launches it
- **Firefox/Chromium app support** — apps that don't expose windows via the Accessibility API (Zen Browser, Chrome, etc.) are now detected via the system window list
- **Background dimming** — adjustable opacity overlay behind the panel for better contrast on bright desktops
- **Liquid Glass design** — uses macOS 26's native `GlassEffectContainer` / `glassEffect` API on supported systems, with a clean fallback on older macOS
- **Screen Recording permission flow** — Preferences shows a live status indicator and a one-click grant button for Screen Recording, mirroring the existing Accessibility flow


## Usage

### Binding
You should start by binding different applications to the number keys. You can do this:
- through **Preferences → Profiles** (accessed through the menu bar), or
- by selecting the application of your choice and then pressing <kbd>Ctrl</kbd> + <kbd>Option</kbd> + <kbd>Shift</kbd>.

### Profiles
You can also set your bindings up in different profiles.

For example, you may want two profiles:
- "Coding": Which binds your favourite editor, browser, and terminal
- "Browsing": Which binds your favourite web browser, messaging app, and music client

You can switch between profiles:
- using the menu bar, or
- by binding them to the number keys, and then pressing <kbd>Ctrl</kbd> + <kbd>Option</kbd> + <kbd>[0-9]</kbd>.

### Switching applications
Suppose you're in your coding profile, and have your editor bound to `0`.

To switch between apps and windows:
1. Hold <kbd>Control</kbd> and press <kbd>0</kbd> to open a panel showing each of your editor's windows.
2. Press <kbd>0</kbd> multiple times to select the specific window you want.
3. Release <kbd>Control</kbd> to switch to the selected window.

In this way, Reef gives every app its own 'Alt-Tab'.

Note that window switching is scoped to your current [macOS space](https://support.apple.com/en-ca/guide/mac-help/mh14112/mac).

### Customization

You can customize the modifiers for switching applications and profiles, and for binding different applications in **Reef Preferences → Shortcuts**.

Reef also pairs well with [Rectangle](https://github.com/rxhanson/Rectangle):
- Rectangle positions & re-arranges your windows
- Reef re-focuses your windows


## Installation

Download the latest release on [GitHub Releases](https://github.com/KaushalKishorMishra/Reef/releases/latest).

Simply: 
1) Download the `.zip` and unzip the file.
2) Drag `Reef.app` into your Applications folder.

If macOS blocks the app on first launch, run the following command in Terminal to remove the quarantine flag:
```bash
xattr -dr com.apple.quarantine /Applications/Reef.app
```

### Compatibility

Reef is compatible with **macOS 14.6 (Sonoma)** and onwards. 

You can find your macOS version from the ** → About This Mac** page.


## Development

Please share issues and feedback via the [GitHub issues page](https://github.com/KaushalKishorMishra/Reef/issues).

Feel free to submit pull requests, though we can't guarantee that we'll get to them.

### Building from Source

**Requirements**
- macOS 14.6 or later
- Xcode 16 or later

**Steps**

1. Clone the repository:
   ```bash
   git clone https://github.com/KaushalKishorMishra/Reef.git
   cd Reef
   ```

2. Open the project in Xcode:
   ```bash
   open Reef/Reef.xcodeproj
   ```
   > If the project uses an `.xcworkspace`, open that instead.

3. Wait for Xcode to resolve the Swift Package dependencies (KeyboardShortcuts, Sparkle). This happens automatically on first open.

4. Select the **Reef** scheme and **My Mac** as the destination in the Xcode toolbar.

5. Press **Cmd+B** to build.

**Installing your build**

1. Quit the running Reef app if it's open (menu bar icon → **Quit**).
2. In Xcode's Project Navigator, expand the **Products** folder at the bottom.
3. Right-click **Reef.app** → **Show in Finder**.
4. Drag `Reef.app` into your `/Applications` folder, replacing any existing copy.
5. Launch Reef from `/Applications`. On first launch after a manual install, macOS Gatekeeper may block it — right-click the app → **Open** → **Open** to allow it once.

Reef requires **Accessibility permission** to manage windows. A prompt will appear on first launch — approve it in **System Settings → Privacy & Security → Accessibility**.


## FAQ
<details>
<summary><b>Why is it called "Reef"?</b></summary>
<br>
The name comes from the starting sounds of the words "refocus" and "reframe". And, like a coral reef supports a diverse ecosystem, Reef supports your workspace—helping you navigate between windows quickly and easily.
</details>


## Related Projects
- [yabai](https://github.com/asmvik/yabai)
- [Aerospace](https://github.com/nikitabobko/AeroSpace?tab=readme-ov-file)
- [Rectangle](https://github.com/rxhanson/Rectangle)
- [AltTab for macOS](https://github.com/lwouis/alt-tab-macos/tree/master)


## Acknowledgements

- Original project by [Xander Gouws](https://github.com/gouwsxander) — [gouwsxander/Reef](https://github.com/gouwsxander/Reef)
- Contributors to the original Reef project
- New features in this fork built with assistance from [Claude](https://claude.ai) by Anthropic
