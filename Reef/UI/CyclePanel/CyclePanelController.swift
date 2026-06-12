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

    private func createPanel() {
        let contentRect = NSRect(x: 0, y: 0, width: previewContentWidth, height: previewContentHeight)
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
    }

    // Called when user presses Ctrl+[number]
    func showSwitcher(for application: Application) {
        currentApplication = application
        state.setApplication(application)

        if !panel.isVisible {
            updatePanelSize()
            panel.center()
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            installFlagsMonitor()
            installKeyDownMonitor()
        } else {
            updatePanelSize()
        }
    }

    private func updatePanelSize() {
        let width  = state.isActionMode ? actionContentWidth  : previewContentWidth
        let height = state.isActionMode ? actionContentHeight : previewContentHeight

        let contentRect = NSRect(x: 0, y: 0, width: width, height: height)
        let targetFrameSize = panel.frameRect(forContentRect: contentRect).size

        let center = CGPoint(x: panel.frame.midX, y: panel.frame.midY)
        let newOrigin = CGPoint(
            x: center.x - targetFrameSize.width / 2,
            y: center.y - targetFrameSize.height / 2
        )
        panel.setFrame(NSRect(origin: newOrigin, size: targetFrameSize), display: true, animate: false)
    }

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

    // Called when user releases Ctrl
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
