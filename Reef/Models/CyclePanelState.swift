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
    @Published var thumbnailHeight: CGFloat = 220
    @Published var actionMode: CyclePanelAction? = nil

    var isActionMode: Bool { actionMode != nil }

    /// Called when thumbnail arrives or action mode resolves asynchronously.
    var onStateChanged: (() -> Void)?

    func setApplication(_ application: Application) {
        applicationTitle = application.title
        applicationIcon = application.icon
        thumbnail = nil
        thumbnailHeight = 220
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
        thumbnailHeight = 220
        actionMode = nil
    }

    // MARK: - Thumbnail capture

    private func capturePreview(windowID: CGWindowID) {
        let screenScale = NSScreen.main?.backingScaleFactor ?? 2.0
        Task {
            if let image = await Self.captureImage(windowID: windowID) {
                // Derive display height from the captured image's actual aspect ratio.
                let h = CGFloat(image.height) / screenScale
                thumbnailHeight = min(280, max(120, h))
                thumbnail = image
                onStateChanged?()
            } else {
                if actionMode == nil { actionMode = .openWindow }
                onStateChanged?()
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

        // Capture at the window's natural aspect ratio (width fixed at 960px = 480pt @2x).
        // Height matches the window's real proportions so there are no black bars in the preview.
        let aspect = scWindow.frame.height / max(1, scWindow.frame.width)
        config.width = 960
        config.height = max(1, min(800, Int(960.0 * aspect)))

        return try? await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
    }
}
