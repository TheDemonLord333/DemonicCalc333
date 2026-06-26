//
//  LandscapeCalculatorView.swift
//  DemonicCalc333
//
//  Adds a scientific keypad (x^2, x^x, sqrt, trig, log, ...) next to the
//  standard keypad when the device is rotated, similar to the stock
//  iPhone Calculator's landscape mode.
//

import SwiftUI

struct LandscapeCalculatorView: View {
    @ObservedObject var engine: CalculatorEngine

    private let spacing: CGFloat = 10

    private let scientificRows: [[String]] = [
        ["π", "e", "x!", "mod"],
        ["x²", "x³", "xˣ", "1/x"],
        ["√x", "∛x", "log", "ln"],
        ["sin", "cos", "tan", "eˣ"]
    ]

    var body: some View {
        GeometryReader { proxy in
            let totalSpacing = spacing * 9
            let columnWidth = (proxy.size.width - totalSpacing) / 8
            let buttonHeight = min(columnWidth, (proxy.size.height - 80 - spacing * 4) / 5)

            HStack(spacing: spacing) {
                scientificPad(columnWidth: columnWidth, buttonHeight: buttonHeight)

                Divider()
                    .overlay(DemonicTheme.discordBlurple.opacity(0.4))

                standardPad(columnWidth: columnWidth, buttonHeight: buttonHeight)
            }
            .padding(.horizontal, spacing)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func scientificPad(columnWidth: CGFloat, buttonHeight: CGFloat) -> some View {
        VStack(spacing: spacing) {
            DemonicTitle()
            ForEach(scientificRows, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { title in
                        CalculatorButtonView(
                            title: title,
                            style: .accent,
                            fontSize: 18
                        ) {
                            engine.perform(scientificAction(for: title))
                        }
                        .frame(width: columnWidth, height: buttonHeight)
                    }
                }
            }
        }
        .frame(width: columnWidth * 4 + spacing * 3)
    }

    @ViewBuilder
    private func standardPad(columnWidth: CGFloat, buttonHeight: CGFloat) -> some View {
        VStack(spacing: spacing) {
            DisplayView(
                expression: engine.expressionPreview,
                text: engine.display,
                preview: engine.resultPreview,
                fontSize: 50
            )

            row(["AC", "±", "%", "÷"], columnWidth: columnWidth, buttonHeight: buttonHeight)
            row(["7", "8", "9", "×"], columnWidth: columnWidth, buttonHeight: buttonHeight)
            row(["4", "5", "6", "−"], columnWidth: columnWidth, buttonHeight: buttonHeight)
            row(["1", "2", "3", "+"], columnWidth: columnWidth, buttonHeight: buttonHeight)
            bottomRow(columnWidth: columnWidth, buttonHeight: buttonHeight)
        }
        .frame(width: columnWidth * 4 + spacing * 3)
    }

    @ViewBuilder
    private func row(_ titles: [String], columnWidth: CGFloat, buttonHeight: CGFloat) -> some View {
        HStack(spacing: spacing) {
            ForEach(titles, id: \.self) { title in
                CalculatorButtonView(
                    title: displayTitle(title),
                    style: style(for: title),
                    fontSize: 20
                ) {
                    engine.perform(action(for: title))
                }
                .frame(width: columnWidth, height: buttonHeight)
            }
        }
    }

    @ViewBuilder
    private func bottomRow(columnWidth: CGFloat, buttonHeight: CGFloat) -> some View {
        HStack(spacing: spacing) {
            CalculatorButtonView(title: "0", style: .digit, fontSize: 20) {
                engine.perform(.digit("0"))
            }
            .frame(width: columnWidth * 2 + spacing, height: buttonHeight)

            CalculatorButtonView(title: ".", style: .digit, fontSize: 20) {
                engine.perform(.decimalPoint)
            }
            .frame(width: columnWidth, height: buttonHeight)

            CalculatorButtonView(title: "=", style: .equals, fontSize: 20) {
                engine.perform(.equals)
            }
            .frame(width: columnWidth, height: buttonHeight)
        }
    }

    private func displayTitle(_ title: String) -> String {
        title == "AC" ? engine.clearLabel : title
    }

    private func style(for title: String) -> CalculatorButtonStyle {
        switch title {
        case "AC", "±", "%": return .function
        case "÷", "×", "−", "+": return .operatorKey
        default: return .digit
        }
    }

    private func action(for title: String) -> CalculatorAction {
        switch title {
        case "AC": return .clear
        case "±": return .toggleSign
        case "%": return .percent
        case "÷": return .operate(.divide)
        case "×": return .operate(.multiply)
        case "−": return .operate(.subtract)
        case "+": return .operate(.add)
        default: return .digit(title)
        }
    }

    private func scientificAction(for title: String) -> CalculatorAction {
        switch title {
        case "mod": return .operate(.mod)
        case "π": return .scientific(.pi)
        case "e": return .scientific(.e)
        case "x!": return .scientific(.factorial)
        case "x²": return .scientific(.square)
        case "x³": return .scientific(.cube)
        case "xˣ": return .scientific(.selfPower)
        case "1/x": return .scientific(.reciprocal)
        case "√x": return .scientific(.squareRoot)
        case "∛x": return .scientific(.cubeRoot)
        case "log": return .scientific(.log)
        case "ln": return .scientific(.ln)
        case "sin": return .scientific(.sin)
        case "cos": return .scientific(.cos)
        case "tan": return .scientific(.tan)
        case "eˣ": return .scientific(.exp)
        default: return .scientific(.pi)
        }
    }
}

#Preview {
    LandscapeCalculatorView(engine: CalculatorEngine())
        .background(DemonicTheme.backgroundGradient)
}
