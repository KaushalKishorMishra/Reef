//
//  CyclePanelView.swift
//  Reef
//
//  Window switcher panel UI
//

import SwiftUI

struct CyclePanelView: View {
    @ObservedObject var state: CyclePanelState
    @AppStorage("panelDimming") private var panelDimming: Double = 0.0

    var body: some View {
        if state.isActionMode, let action = state.actionMode {
            actionCard(action: action)
        } else {
            previewCard
        }
    }

    // MARK: - Preview card (app has windows)

    private var previewCard: some View {
        VStack(spacing: 0) {
            header
            Divider()
                .background(Color.white.opacity(0.2))
            thumbnailArea
        }
        .frame(width: 480)
        .background(Color.black.opacity(panelDimming))
    }

    private var header: some View {
        HStack(spacing: 10) {
            if let icon = state.applicationIcon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 32, height: 32)
            }
            Text(state.applicationTitle)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private var thumbnailArea: some View {
        if let thumbnail = state.thumbnail {
            Image(decorative: thumbnail, scale: 1.0)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 480, height: 300)
                .clipped()
        } else {
            ZStack {
                Color.white.opacity(0.05)
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.8)
                    .tint(.white)
            }
            .frame(width: 480, height: 300)
        }
    }

    // MARK: - Action card (no windows / app not running)

    private func actionCard(action: CyclePanelAction) -> some View {
        VStack(spacing: 10) {
            if let icon = state.applicationIcon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 56, height: 56)
            }
            Text(state.applicationTitle)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(1)
            Text(action.subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.55))
            Text(action.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.white.opacity(0.18)))
        }
        .frame(width: 320)
        .padding(.vertical, 28)
    }
}
