//
//  Theme.swift
//  DemonicCalc333
//
//  Discord x Spotify inspired color palette with a demonic twist.
//

import SwiftUI

enum DemonicTheme {
    // Discord-style dark background, deepened toward black for the "demonic" feel.
    static let background = Color(red: 0.04, green: 0.03, blue: 0.06)
    static let surface = Color(red: 0.09, green: 0.07, blue: 0.11)

    // Discord indigo / blurple.
    static let discordBlurple = Color(red: 0x58 / 255, green: 0x65 / 255, blue: 0xF2 / 255)
    // Spotify green.
    static let spotifyGreen = Color(red: 0x1E / 255, green: 0xD7 / 255, blue: 0x60 / 255)
    // Blood red accent for the demonic equals/operator buttons.
    static let infernoRed = Color(red: 0.78, green: 0.06, blue: 0.12)
    static let infernoRedDeep = Color(red: 0.45, green: 0.02, blue: 0.06)

    static let digitButton = Color(red: 0.16, green: 0.13, blue: 0.20)
    static let functionButton = Color(red: 0.12, green: 0.10, blue: 0.16)

    static let primaryText = Color.white
    static let secondaryText = Color(red: 0.72, green: 0.68, blue: 0.78)

    static let glow = discordBlurple.opacity(0.55)

    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.02, blue: 0.07),
            Color(red: 0.10, green: 0.04, blue: 0.10),
            Color(red: 0.04, green: 0.03, blue: 0.06)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let operatorGradient = LinearGradient(
        colors: [discordBlurple, Color(red: 0.34, green: 0.18, blue: 0.62)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let equalsGradient = LinearGradient(
        colors: [infernoRed, infernoRedDeep],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [spotifyGreen, Color(red: 0.07, green: 0.55, blue: 0.34)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
