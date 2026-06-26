//
//  PortraitCalculatorView.swift
//  DemonicCalc333
//
//  Mirrors the classic stock iPhone Calculator layout (4x5 grid).
//

import SwiftUI

struct PortraitCalculatorView: View {
    @ObservedObject var engine: CalculatorEngine

    private let spacing: CGFloat = 12

    var body: some View {
        GeometryReader { proxy in
            let buttonSize = (proxy.size.width - spacing * 5) / 4

            VStack(spacing: 16) {
                DemonicTitle()
                    .padding(.top, 8)

                Spacer(minLength: 0)

                DisplayView(text: engine.display, fontSize: 72)
                    .padding(.horizontal, 4)

                VStack(spacing: spacing) {
                    row(["AC", "±", "%", "÷"], buttonSize: buttonSize)
                    row(["7", "8", "9", "×"], buttonSize: buttonSize)
                    row(["4", "5", "6", "−"], buttonSize: buttonSize)
                    row(["1", "2", "3", "+"], buttonSize: buttonSize)
                    bottomRow(buttonSize: buttonSize)
                }
            }
            .padding(.horizontal, spacing)
            .padding(.bottom, spacing)
        }
    }

    @ViewBuilder
    private func row(_ titles: [String], buttonSize: CGFloat) -> some View {
        HStack(spacing: spacing) {
            ForEach(titles, id: \.self) { title in
                CalculatorButtonView(
                    title: displayTitle(title),
                    style: style(for: title),
                    fontSize: 30
                ) {
                    engine.perform(action(for: title))
                }
                .frame(width: buttonSize, height: buttonSize)
            }
        }
    }

    @ViewBuilder
    private func bottomRow(buttonSize: CGFloat) -> some View {
        HStack(spacing: spacing) {
            CalculatorButtonView(title: "0", style: .digit, fontSize: 30) {
                engine.perform(.digit("0"))
            }
            .frame(width: buttonSize * 2 + spacing, height: buttonSize)

            CalculatorButtonView(title: ".", style: .digit, fontSize: 30) {
                engine.perform(.decimalPoint)
            }
            .frame(width: buttonSize, height: buttonSize)

            CalculatorButtonView(title: "=", style: .equals, fontSize: 30) {
                engine.perform(.equals)
            }
            .frame(width: buttonSize, height: buttonSize)
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
}

#Preview {
    PortraitCalculatorView(engine: CalculatorEngine())
        .background(DemonicTheme.backgroundGradient)
}
