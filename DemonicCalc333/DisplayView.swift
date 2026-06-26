//
//  DisplayView.swift
//  DemonicCalc333
//

import SwiftUI

struct DisplayView: View {
    let text: String
    let fontSize: CGFloat

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .light, design: .rounded))
            .foregroundStyle(DemonicTheme.primaryText)
            .minimumScaleFactor(0.35)
            .lineLimit(1)
            .shadow(color: DemonicTheme.discordBlurple.opacity(0.6), radius: 12)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct DemonicTitle: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .foregroundStyle(DemonicTheme.infernoRed)
            Text("DEMONIC CALC")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(DemonicTheme.secondaryText)
            Image(systemName: "flame.fill")
                .foregroundStyle(DemonicTheme.spotifyGreen)
        }
    }
}
