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

    private let panelWidth: CGFloat  = 280
    private let panelHeight: CGFloat = 176

    override init() {
        super.init()
        createPanel()
    }

    private func createPanel() {
        let contentRect = NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight)
        panel = CyclePanel(contentRect: contentRect)

        let hostingView = NSHostingView(rootView: CyclePanelView(state: state))
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

    // MARK: - Switcher lifecycle

    func showSwitcher(for application: Application) {
        currentApplication = application
        state.setApplication(application)

        if !panel.isVisible {
            positionPanelBelowMenuBar()
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            installFlagsMonitor()
            installKeyDownMonitor()
        }
    }

    private func positionPanelBelowMenuBar() {
        guard let screen = NSScreen.main else { panel.center(); return }
        let frameSize = panel.frame.size
        let x = max(8, min(screen.frame.width - frameSize.width - 8,
                            screen.frame.midX - frameSize.width / 2))
        let y = screen.visibleFrame.maxY - frameSize.height - 8
        panel.setFrameOrigin(CGPoint(x: x, y: y))
    }

    // MARK: - App activation

    func isShowingSwitcher(for application: Application) -> Bool {
        guard let current = currentApplication else { return false }
        if let a = current.bundleIdentifier, let b = application.bundleIdentifier { return a == b }
        if let a = current.bundleUrl, let b = application.bundleUrl { return a == b }
        return current.title == application.title
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
        if let m = flagsMonitor { NSEvent.removeMonitor(m); flagsMonitor = nil }
    }

    private func installKeyDownMonitor() {
        guard keyDownMonitor == nil else { return }
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.panel.isVisible else { return event }
            if event.keyCode == 53 { Task { @MainActor in self.hideSwitcher() }; return nil }
            return event
        }
    }

    private func removeKeyDownMonitor() {
        if let m = keyDownMonitor { NSEvent.removeMonitor(m); keyDownMonitor = nil }
    }

    deinit {
        if let m = flagsMonitor  { NSEvent.removeMonitor(m) }
        if let m = keyDownMonitor { NSEvent.removeMonitor(m) }
    }
}
