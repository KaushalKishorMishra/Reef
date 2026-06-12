//
//  PreferencesGeneralView.swift
//  Reef
//
//  Created by Xander Gouws on 26-01-2026.
//

import SwiftUI
import ServiceManagement
import ApplicationServices
import CoreGraphics

struct PreferencesGeneralView: View {
    @AppStorage("launchOnLogin") private var launchOnLogin = true
    @AppStorage("defaultNumberOrder") private var defaultNumberOrder = "rightHanded"
    @AppStorage("panelDimming") private var panelDimming: Double = 0.0

    @State private var hasAccessibilityPermission = AXIsProcessTrusted()
    @State private var hasScreenRecordingPermission = CGPreflightScreenCaptureAccess()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Form {
            // Accessibility permission banner (required — app won't work without it)
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

            Section {
                // Window previews permission status — always visible
                HStack(spacing: 10) {
                    Image(systemName: hasScreenRecordingPermission
                          ? "checkmark.circle.fill"
                          : "exclamationmark.circle.fill")
                        .foregroundStyle(hasScreenRecordingPermission ? Color.green : Color.yellow)
                        .imageScale(.large)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Window Previews")
                            .fontWeight(.medium)
                        Text(hasScreenRecordingPermission
                             ? "Screen Recording granted"
                             : "Screen Recording not granted")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if !hasScreenRecordingPermission {
                        Button("Grant Access", action: openScreenRecordingSettings)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                    }
                }

                // Background dimming slider
                HStack {
                    Text("Background dimming")
                    Spacer()
                    Text("\(Int(panelDimming * 100))%")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .frame(width: 36, alignment: .trailing)
                }
                Slider(value: $panelDimming, in: 0.0...0.6, step: 0.05)
            } header: {
                Text("Switcher Panel")
            } footer: {
                Text("Window previews require Screen Recording. Dimming darkens the panel background for better contrast on bright desktops.")
            }
        }
        .formStyle(.grouped)
        .frame(height: dynamicHeight)
        .onAppear {
            refreshPermissions()
        }
        .onReceive(timer) { _ in
            refreshPermissions()
        }
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
                Text(title)
                    .fontWeight(.medium)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("Open Settings", action: action)
                .buttonStyle(.borderedProminent)
        }
    }

    private var dynamicHeight: CGFloat {
        var height: CGFloat = 290   // base: login + number order + switcher section (with previews row)
        if !hasAccessibilityPermission { height += 68 }
        return height
    }

    private func refreshPermissions() {
        hasAccessibilityPermission = AXIsProcessTrusted()
        hasScreenRecordingPermission = CGPreflightScreenCaptureAccess()
    }

    private func openAccessibilitySettings() {
        // Triggers the system Accessibility permission dialog (same pattern as CGRequestScreenCaptureAccess).
        // If the dialog can't be shown (already denied), falls back to opening System Settings.
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        if !AXIsProcessTrustedWithOptions(options) {
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
        }
    }

    private func openScreenRecordingSettings() {
        // Triggers the system permission dialog and adds Reef to the Screen Recording list.
        // Falls back to opening System Settings if the request returns false (e.g. already denied).
        if !CGRequestScreenCaptureAccess() {
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!
            NSWorkspace.shared.open(url)
        }
    }

    private func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
                DispatchQueue.main.async {
                    launchOnLogin = !enabled
                }
            }
        } else {
            SMLoginItemSetEnabled(Bundle.main.bundleIdentifier! as CFString, enabled)
        }
    }
}

#Preview {
    PreferencesGeneralView()
}
