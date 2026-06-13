//
//  CyclePanelView.swift
//  Reef
//
//  Window switcher panel UI
//

import SwiftUI

struct CyclePanelView: View {
    @ObservedObject var state: CyclePanelState

    var body: some View {
        actionCard(action: state.actionMode)
    }

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
        .frame(width: 280)
        .padding(.vertical, 28)
    }
}
