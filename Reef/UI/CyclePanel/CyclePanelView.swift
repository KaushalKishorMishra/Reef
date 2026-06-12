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
                .background(Color.white.opacity(0.15))
            thumbnailArea
        }
        .frame(width: 480)
        .background(Color.black.opacity(panelDimming))
    }

    private var header: some View {
        HStack(spacing: 12) {
            if let icon = state.applicationIcon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            }
            Text(state.applicationTitle)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private var thumbnailArea: some View {
        if let thumbnail = state.thumbnail {
            Image(decorative: thumbnail, scale: 1.0)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 480, height: state.thumbnailHeight)
                .clipped()
        } else {
            ZStack {
                Color.white.opacity(0.05)
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.8)
                    .tint(.white)
            }
            .frame(width: 480, height: state.thumbnailHeight)
        }
    }

    // MARK: - Action card (no windows / app not running)

    private func actionCard(action: CyclePanelAction) -> some View {
        VStack(spacing: 8) {
            if let icon = state.applicationIcon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            Text(state.applicationTitle)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
            Text(action.subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
            Text(action.title)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.85))
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color.white.opacity(0.15)))
        }
        .frame(width: 320)
        .padding(.vertical, 28)
    }
}
