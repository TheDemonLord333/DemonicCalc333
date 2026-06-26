//
//  DisplayView.swift
//  DemonicCalc333
//

import SwiftUI

struct DisplayView: View {
    let expression: String
    let text: String
    let preview: String
    let fontSize: CGFloat

    init(expression: String = "", text: String, preview: String = "", fontSize: CGFloat) {
        self.expression = expression
        self.text = text
        self.preview = preview
        self.fontSize = fontSize
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            if !expression.isEmpty {
                Text(expression)
                    .font(.system(size: fontSize * 0.28, weight: .regular, design: .rounded))
                    .foregroundStyle(DemonicTheme.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }

            Text(text)
                .font(.system(size: fontSize, weight: .light, design: .rounded))
                .foregroundStyle(DemonicTheme.primaryText)
                .minimumScaleFactor(0.35)
                .lineLimit(1)
                .shadow(color: DemonicTheme.discordBlurple.opacity(0.6), radius: 12)

            if !preview.isEmpty {
                Text(preview)
                    .font(.system(size: fontSize * 0.34, weight: .medium, design: .rounded))
                    .foregroundStyle(DemonicTheme.spotifyGreen)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .shadow(color: DemonicTheme.spotifyGreen.opacity(0.5), radius: 6)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.15), value: preview)
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
