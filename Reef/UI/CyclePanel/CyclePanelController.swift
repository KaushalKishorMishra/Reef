//
//  CyclePanelController.swift
//  Reef
//
//  Created by Xander Gouws on 23-01-2026.
//

import AppKit
import SwiftUI


@MainActor
final class CyclePanelController: NSObject {
    private(set) var panel: CyclePanel!
    private let state = CyclePanelState()
    private var flagsMonitor: Any?
    private var keyDownMonitor: Any?
    private var currentApplication: Application?

    // Preview card: header (60) + divider (1) + thumbnail (300)
    private let previewContentWidth: CGFloat  = 480
    private let previewContentHeight: CGFloat = 361

    // Action card (no windows / not running)
    private let actionContentWidth: CGFloat  = 320
    private let actionContentHeight: CGFloat = 176

    override init() {
        super.init()
        createPanel()
    }

    private var previewPanelHeight: CGFloat { 61 + state.thumbnailHeight }

    private func createPanel() {
        let contentRect = NSRect(x: 0, y: 0, width: previewContentWidth, height: previewPanelHeight)
        panel = CyclePanel(contentRect: contentRect)

        let contentView = CyclePanelView(state: state)
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        guard let containerView = panel.contentView else { return }
        containerView.addSubview(hostingView)
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        state.onStateChanged = { [weak self] in
            self?.handleAsyncStateChange()
        }
    }

    private func handleAsyncStateChange() {
        guard panel.isVisible else { return }
        updatePanelSize()
        positionPanelBelowMenuBar()
    }

    // MARK: - Switcher lifecycle

    func showSwitcher(for application: Application) {
        currentApplication = application
        state.setApplication(application)

        if !panel.isVisible {
            updatePanelSize()
            positionPanelBelowMenuBar()
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            installFlagsMonitor()
            installKeyDownMonitor()
        } else {
            updatePanelSize()
            positionPanelBelowMenuBar()
        }
    }

    // MARK: - Panel sizing and positioning

    private func updatePanelSize() {
        let width  = state.isActionMode ? actionContentWidth  : previewContentWidth
        let height = state.isActionMode ? actionContentHeight : previewPanelHeight
        let contentRect = NSRect(x: 0, y: 0, width: width, height: height)
        let targetSize = panel.frameRect(forContentRect: contentRect).size
        // Anchor to top edge when height changes so panel grows downward.
        let topY = panel.frame.maxY
        let newOrigin = CGPoint(x: panel.frame.origin.x, y: topY - targetSize.height)
        panel.setFrame(NSRect(origin: newOrigin, size: targetSize), display: true, animate: false)
    }

    /// Positions the panel horizontally centered on the main screen, just below the menu bar.
    private func positionPanelBelowMenuBar() {
        guard let screen = NSScreen.main else {
            panel.center()
            return
        }
        let frameSize = panel.frame.size
        let gap: CGFloat = 8
        let x = max(8, min(screen.frame.width - frameSize.width - 8,
                            screen.frame.midX - frameSize.width / 2))
        let y = screen.visibleFrame.maxY - frameSize.height - gap
        panel.setFrameOrigin(CGPoint(x: x, y: y))
    }

    // MARK: - App activation

    func isShowingSwitcher(for application: Application) -> Bool {
        guard let currentApplication else { return false }

        if let currentBundleID = currentApplication.bundleIdentifier,
           let targetBundleID = application.bundleIdentifier {
            return currentBundleID == targetBundleID
        }

        if let currentURL = currentApplication.bundleUrl,
           let targetURL = application.bundleUrl {
            return currentURL == targetURL
        }

        return currentApplication.title == application.title
    }

    func activateApp() {
        let application = currentApplication
        hideSwitcher()

        Task { @MainActor in
            guard let application else { return }
            let success = await application.performNoWindowAction()
            if !success { NSSound.beep() }
        }
    }

    private func hideSwitcher() {
        removeFlagsMonitor()
        removeKeyDownMonitor()
        panel.orderOut(nil)
        state.reset()
        currentApplication = nil
    }

    // MARK: - Event monitors

    private func installFlagsMonitor() {
        guard flagsMonitor == nil else { return }

        flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self else { return event }
            if !event.modifierFlags.contains(.control) {
                Task { @MainActor in self.activateApp() }
            }
            return event
        }
    }

    private func removeFlagsMonitor() {
        if let monitor = flagsMonitor {
            NSEvent.removeMonitor(monitor)
            flagsMonitor = nil
        }
    }

    private func installKeyDownMonitor() {
        guard keyDownMonitor == nil else { return }

        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.panel.isVisible else { return event }

            if event.keyCode == 53 { // Escape — close without switching
                Task { @MainActor in self.hideSwitcher() }
                return nil
            }

            return event
        }
    }

    private func removeKeyDownMonitor() {
        if let monitor = keyDownMonitor {
            NSEvent.removeMonitor(monitor)
            keyDownMonitor = nil
        }
    }

    deinit {
        if let monitor = flagsMonitor  { NSEvent.removeMonitor(monitor) }
        if let monitor = keyDownMonitor { NSEvent.removeMonitor(monitor) }
    }
}
