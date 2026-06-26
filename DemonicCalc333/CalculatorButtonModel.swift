//
//  CalculatorButtonModel.swift
//  DemonicCalc333
//

import SwiftUI

enum CalculatorButtonStyle {
    case digit
    case function
    case operatorKey
    case equals
    case accent // scientific/landscape-only keys
}

struct CalculatorButtonModel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let style: CalculatorButtonStyle
    let action: CalculatorAction

    static func == (lhs: CalculatorButtonModel, rhs: CalculatorButtonModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum CalculatorAction: Hashable {
    case digit(String)
    case decimalPoint
    case clear
    case toggleSign
    case percent
    case operate(CalculatorOperation)
    case equals
    case scientific(ScientificFunction)
    case openParen
    case closeParen
}

enum CalculatorOperation: String, Hashable {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
    case power = "xʸ"
    case mod = "mod"
}

enum ScientificFunction: String, Hashable {
    case square = "x²"
    case cube = "x³"
    case selfPower = "xˣ"
    case squareRoot = "√x"
    case cubeRoot = "∛x"
    case reciprocal = "1/x"
    case factorial = "x!"
    case sin
    case cos
    case tan
    case log
    case ln
    case exp = "eˣ"
    case tenPower = "10ˣ"
    case pi = "π"
    case e
}
