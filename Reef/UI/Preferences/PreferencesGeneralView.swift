//
//  PreferencesGeneralView.swift
//  Reef
//
//  Created by Xander Gouws on 26-01-2026.
//

import SwiftUI
import ServiceManagement
import ApplicationServices

struct PreferencesGeneralView: View {
    @AppStorage("launchOnLogin") private var launchOnLogin = true
    @AppStorage("defaultNumberOrder") private var defaultNumberOrder = "rightHanded"

    @State private var hasAccessibilityPermission = AXIsProcessTrusted()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Form {
            if !hasAccessibilityPermission {
                permissionBanner(
                    title: "Accessibility Permission Required",
                    detail: "System Settings → Privacy & Security → Accessibility",
                    action: openAccessibilitySettings
                )
            }

            Section {
                Toggle("Launch Reef at login", isOn: $launchOnLogin)
                    .onChange(of: launchOnLogin) { _, newValue in
                        setLaunchAtLogin(enabled: newValue)
                    }

                Picker("Default number order:", selection: $defaultNumberOrder) {
                    Text("Right handed (0, 9, ..., 1)").tag("rightHanded")
                    Text("Left handed (1, ..., 9, 0)").tag("leftHanded")
                }
                .pickerStyle(.menu)
            } footer: {
                Text("Number order sets the order in which numbers are displayed in the menubar")
            }
        }
        .formStyle(.grouped)
        .frame(height: dynamicHeight)
        .onAppear { refreshPermissions() }
        .onReceive(timer) { _ in refreshPermissions() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refreshPermissions()
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func permissionBanner(title: String, detail: String, action: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
                .imageScale(.large)

            VStack(alignment: .leading, spacing: 4) {
                Text(title).fontWeight(.medium)
                Text(detail).font(.caption).foregroundColor(.secondary)
            }

            Spacer()

            Button("Open Settings", action: action)
                .buttonStyle(.borderedProminent)
        }
    }

    private var dynamicHeight: CGFloat {
        hasAccessibilityPermission ? 180 : 248
    }

    private func refreshPermissions() {
        hasAccessibilityPermission = AXIsProcessTrusted()
    }

    private func openAccessibilitySettings() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        if !AXIsProcessTrustedWithOptions(options) {
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
        }
    }

    private func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled { try SMAppService.mainApp.register() }
                else { try SMAppService.mainApp.unregister() }
            } catch {
                DispatchQueue.main.async { launchOnLogin = !enabled }
            }
        } else {
            SMLoginItemSetEnabled(Bundle.main.bundleIdentifier! as CFString, enabled)
        }
    }
}

#Preview {
    PreferencesGeneralView()
}
