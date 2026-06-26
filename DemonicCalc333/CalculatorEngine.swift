//
//  CalculatorEngine.swift
//  DemonicCalc333
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class CalculatorEngine: ObservableObject {
    @Published private(set) var display: String = "0"

    private var currentValue: Double = 0
    private var pendingOperation: CalculatorOperation?
    private var accumulator: Double = 0
    private var isEnteringNumber = false
    private var justEvaluated = false

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 9
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    func perform(_ action: CalculatorAction) {
        switch action {
        case .digit(let digit):
            appendDigit(digit)
        case .decimalPoint:
            appendDecimalPoint()
        case .clear:
            clear()
        case .toggleSign:
            toggleSign()
        case .percent:
            applyPercent()
        case .operate(let operation):
            applyOperator(operation)
        case .equals:
            evaluate()
        case .scientific(let function):
            applyScientific(function)
        }
    }

    var clearLabel: String {
        (currentValue == 0 && !isEnteringNumber && pendingOperation == nil) ? "AC" : "C"
    }

    private func appendDigit(_ digit: String) {
        if justEvaluated {
            display = "0"
            justEvaluated = false
        }
        if !isEnteringNumber || display == "0" {
            display = digit
            isEnteringNumber = true
        } else {
            guard display.count < 15 else { return }
            display += digit
        }
        currentValue = Double(display) ?? 0
    }

    private func appendDecimalPoint() {
        if justEvaluated {
            display = "0"
            justEvaluated = false
        }
        if !isEnteringNumber {
            display = "0."
            isEnteringNumber = true
        } else if !display.contains(".") {
            display += "."
        }
        currentValue = Double(display) ?? currentValue
    }

    private func clear() {
        if isEnteringNumber {
            display = "0"
            currentValue = 0
            isEnteringNumber = false
        } else {
            display = "0"
            currentValue = 0
            accumulator = 0
            pendingOperation = nil
        }
        justEvaluated = false
    }

    private func toggleSign() {
        currentValue *= -1
        display = format(currentValue)
        isEnteringNumber = true
    }

    private func applyPercent() {
        currentValue /= 100
        display = format(currentValue)
        isEnteringNumber = true
    }

    private func applyOperator(_ operation: CalculatorOperation) {
        if let pending = pendingOperation, isEnteringNumber {
            accumulator = calculate(accumulator, currentValue, pending)
            display = format(accumulator)
        } else {
            accumulator = currentValue
        }
        pendingOperation = operation
        isEnteringNumber = false
        justEvaluated = false
    }

    private func evaluate() {
        guard let pending = pendingOperation else {
            justEvaluated = true
            return
        }
        accumulator = calculate(accumulator, currentValue, pending)
        display = format(accumulator)
        currentValue = accumulator
        pendingOperation = nil
        isEnteringNumber = false
        justEvaluated = true
    }

    private func calculate(_ lhs: Double, _ rhs: Double, _ operation: CalculatorOperation) -> Double {
        switch operation {
        case .add: return lhs + rhs
        case .subtract: return lhs - rhs
        case .multiply: return lhs * rhs
        case .divide: return rhs == 0 ? .nan : lhs / rhs
        case .power: return pow(lhs, rhs)
        }
    }

    private func applyScientific(_ function: ScientificFunction) {
        let value = currentValue
        let result: Double
        switch function {
        case .square: result = pow(value, 2)
        case .cube: result = pow(value, 3)
        case .selfPower: result = pow(value, value)
        case .squareRoot: result = sqrt(value)
        case .cubeRoot: result = cbrt(value)
        case .reciprocal: result = value == 0 ? .nan : 1 / value
        case .factorial: result = factorial(value)
        case .sin: result = sin(value * .pi / 180)
        case .cos: result = cos(value * .pi / 180)
        case .tan: result = tan(value * .pi / 180)
        case .log: result = log10(value)
        case .ln: result = log(value)
        case .exp: result = exp(value)
        case .tenPower: result = pow(10, value)
        case .pi: result = .pi
        case .e: result = M_E
        case .mod:
            if let pending = pendingOperation, isEnteringNumber {
                accumulator = accumulator.truncatingRemainder(dividingBy: currentValue)
                display = format(accumulator)
                pendingOperation = nil
                isEnteringNumber = false
                justEvaluated = true
                _ = pending
                return
            } else {
                accumulator = currentValue
                pendingOperation = .divide
                return
            }
        }
        currentValue = result
        display = format(result)
        isEnteringNumber = true
        justEvaluated = false
    }

    private func factorial(_ value: Double) -> Double {
        guard value >= 0, value == value.rounded(), value <= 170 else { return .nan }
        var result = 1.0
        var current = 2.0
        while current <= value {
            result *= current
            current += 1
        }
        return result
    }

    private func format(_ value: Double) -> String {
        if value.isNaN { return "Error" }
        if value.isInfinite { return value > 0 ? "∞" : "-∞" }
        if abs(value) > 999_999_999 || (abs(value) < 0.000001 && value != 0) {
            return scientificFormat(value)
        }
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func scientificFormat(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.maximumFractionDigits = 6
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
