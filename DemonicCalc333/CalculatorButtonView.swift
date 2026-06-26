//
//  CalculatorButtonView.swift
//  DemonicCalc333
//

import SwiftUI

struct CalculatorButtonView: View {
    let title: String
    let style: CalculatorButtonStyle
    let isWide: Bool
    let fontSize: CGFloat
    let action: () -> Void

    @State private var isPressed = false

    init(title: String, style: CalculatorButtonStyle, isWide: Bool = false, fontSize: CGFloat = 28, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.isWide = isWide
        self.fontSize = fontSize
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: fontSize, weight: .medium, design: .rounded))
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(DemonicButtonStyle(style: style))
    }

    private var textColor: Color {
        switch style {
        case .equals, .operatorKey:
            return .white
        default:
            return DemonicTheme.primaryText
        }
    }
}

private struct DemonicButtonStyle: ButtonStyle {
    let style: CalculatorButtonStyle

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(background(pressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: 999, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .strokeBorder(borderColor.opacity(configuration.isPressed ? 0.9 : 0.4), lineWidth: 1)
            )
            .shadow(color: glowColor.opacity(configuration.isPressed ? 0.8 : 0.35), radius: configuration.isPressed ? 10 : 6)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    @ViewBuilder
    private func background(pressed: Bool) -> some View {
        switch style {
        case .digit:
            DemonicTheme.digitButton.opacity(pressed ? 0.7 : 1)
        case .function:
            DemonicTheme.functionButton.opacity(pressed ? 0.7 : 1)
        case .operatorKey:
            DemonicTheme.operatorGradient.opacity(pressed ? 0.75 : 1)
        case .equals:
            DemonicTheme.equalsGradient.opacity(pressed ? 0.75 : 1)
        case .accent:
            DemonicTheme.accentGradient.opacity(pressed ? 0.75 : 1)
        }
    }

    private var borderColor: Color {
        switch style {
        case .operatorKey: return DemonicTheme.discordBlurple
        case .equals: return DemonicTheme.infernoRed
        case .accent: return DemonicTheme.spotifyGreen
        default: return Color.white.opacity(0.08)
        }
    }

    private var glowColor: Color {
        switch style {
        case .operatorKey: return DemonicTheme.discordBlurple
        case .equals: return DemonicTheme.infernoRed
        case .accent: return DemonicTheme.spotifyGreen
        default: return .clear
        }
    }
}
