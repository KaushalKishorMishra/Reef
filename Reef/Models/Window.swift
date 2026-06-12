//
//  Window.swift
//  Reef
//
//  Created by Xander Gouws on 12-09-2025.
//

import Foundation
import Cocoa


class Window: Identifiable {
    var id: CGWindowID { cgWindowID ?? 0 }
    var element: AXUIElement?
    var cgWindowID: CGWindowID?
    var application: Application
    private var fallbackTitle: String?

    // Standard init via Accessibility API
    init(_ element: AXUIElement, _ application: Application) {
        self.element = element
        self.cgWindowID = element.getWindowID()
        self.application = application
    }

    // Fallback init when AX is unavailable (e.g. Firefox-based apps)
    init(cgWindowID: CGWindowID, title: String?, application: Application) {
        self.element = nil
        self.cgWindowID = cgWindowID
        self.fallbackTitle = title
        self.application = application
    }

    var title: String {
        if let t = fallbackTitle, !t.isEmpty { return t }
        if let t: String = element?.getAttributeValue(.title) { return t }
        return application.title
    }

    func focus() {
        if let element = element {
            do {
                try element.performAction(.raise)
                application.activate()
                return
            } catch {}
        }
        // No AX element — activate the app; the OS surfaces the most-recently-used window.
        application.activate()
    }

    static func getFrontWindow() -> Window? {
        guard let frontApplication = Application.getFrontApplication() else {
            return nil
        }

        if let focusedWindow = frontApplication.getFocusedWindow() {
            return focusedWindow
        }

        if let firstWindow = frontApplication.getFirstWindow() {
            return firstWindow
        }

        return nil
    }
}
