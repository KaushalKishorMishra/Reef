//
//  CyclePanelState.swift
//  Reef
//
//  Created by Xander Gouws on 23-01-2026.
//

import Foundation
import AppKit
import ScreenCaptureKit

enum CyclePanelAction {
    case launchApp
    case openWindow

    var title: String {
        switch self {
        case .launchApp: return "Launch"
        case .openWindow: return "Focus"
        }
    }

    var subtitle: String {
        switch self {
        case .launchApp: return "Release to launch"
        case .openWindow: return "Release to focus"
        }
    }
}

@MainActor
final class CyclePanelState: ObservableObject {
    @Published var applicationTitle: String = ""
    @Published var applicationIcon: NSImage? = nil
    @Published var thumbnail: CGImage? = nil
    @Published var actionMode: CyclePanelAction? = nil

    var isActionMode: Bool { actionMode != nil }

    func setApplication(_ application: Application) {
        applicationTitle = application.title
        applicationIcon = application.icon
        thumbnail = nil
        actionMode = nil

        let windows = application.getWindows()
        if windows.isEmpty {
            actionMode = application.isRunning ? .openWindow : .launchApp
        } else if let windowID = windows.first?.cgWindowID {
            capturePreview(windowID: windowID)
        }
    }

    func reset() {
        applicationTitle = ""
        applicationIcon = nil
        thumbnail = nil
        actionMode = nil
    }

    // MARK: - Thumbnail capture

    private func capturePreview(windowID: CGWindowID) {
        Task {
            if let image = await Self.captureImage(windowID: windowID) {
                thumbnail = image
            } else {
                // Capture failed — window is gone or Screen Recording not granted.
                // Show the focus action card so the user isn't stuck on a spinner.
                if actionMode == nil {
                    actionMode = .openWindow
                }
            }
        }
    }

    private static nonisolated func captureImage(windowID: CGWindowID) async -> CGImage? {
        guard let content = try? await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false) else {
            return nil
        }

        guard let scWindow = content.windows.first(where: { $0.windowID == windowID }) else {
            return nil
        }

        let filter = SCContentFilter(desktopIndependentWindow: scWindow)
        let config = SCStreamConfiguration()
        config.width = 960
        config.height = 600

        return try? await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
    }
}
