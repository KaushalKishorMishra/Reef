//
//  CyclePanelState.swift
//  Reef
//
//  Created by Xander Gouws on 23-01-2026.
//

import Foundation
import AppKit

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
    @Published var actionMode: CyclePanelAction = .openWindow

    func setApplication(_ application: Application) {
        applicationTitle = application.title
        applicationIcon = application.icon
        actionMode = application.isRunning ? .openWindow : .launchApp
    }

    func reset() {
        applicationTitle = ""
        applicationIcon = nil
        actionMode = .openWindow
    }
}
