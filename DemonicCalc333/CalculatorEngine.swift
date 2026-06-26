//
//  CalculatorEngine.swift
//  DemonicCalc333
//
//  Token-based expression engine: supports parentheses and operator
//  precedence (^ before × ÷ mod before + −) and exposes a live preview
//  of the result while the expression is still being typed.
//

import Combine
import Foundation
import SwiftUI

private enum Token {
    case number(Double, String)
    case op(CalculatorOperation)
    case openParen
    case closeParen

    var displayString: String {
        switch self {
        case .number(_, let raw): return raw
        case .op(let operation): return operation.rawValue
        case .openParen: return "("
        case .closeParen: return ")"
        }
    }
}

@MainActor
final class CalculatorEngine: ObservableObject {
    @Published private(set) var display: String = "0"
    @Published private(set) var expressionPreview: String = ""
    @Published private(set) var resultPreview: String = ""

    private var tokens: [Token] = []
    private var currentEntry: String = ""
    private var justEvaluated = false

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 9
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    var clearLabel: String {
        (currentEntry.isEmpty && tokens.isEmpty) ? "AC" : "C"
    }

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
            evaluateAll()
        case .scientific(let function):
            applyScientific(function)
        case .openParen:
            openParen()
        case .closeParen:
            closeParen()
        }
        updatePreview()
    }

    // MARK: - Digit entry

    private func appendDigit(_ digit: String) {
        if justEvaluated {
            tokens = []
            currentEntry = ""
            justEvaluated = false
        }
        if currentEntry.isEmpty || currentEntry == "0" {
            currentEntry = digit
        } else {
            guard currentEntry.count < 15 else { return }
            currentEntry += digit
        }
        display = currentEntry
    }

    private func appendDecimalPoint() {
        if justEvaluated {
            tokens = []
            currentEntry = ""
            justEvaluated = false
        }
        if currentEntry.isEmpty {
            currentEntry = "0."
        } else if !currentEntry.contains(".") {
            currentEntry += "."
        }
        display = currentEntry
    }

    // MARK: - Clear / sign / percent

    private func clear() {
        if !currentEntry.isEmpty {
            currentEntry = ""
            display = "0"
        } else {
            tokens = []
            display = "0"
        }
        justEvaluated = false
    }

    private func toggleSign() {
        if currentEntry.isEmpty {
            guard let value = Double(display) else { return }
            display = format(-value)
            currentEntry = display
        } else if currentEntry.hasPrefix("-") {
            currentEntry.removeFirst()
            display = currentEntry
        } else {
            currentEntry = "-" + currentEntry
            display = currentEntry
        }
    }

    private func applyPercent() {
        let raw = currentEntry.isEmpty ? display : currentEntry
        guard let value = Double(raw) else { return }
        currentEntry = format(value / 100)
        display = currentEntry
    }

    // MARK: - Operators

    private func applyOperator(_ operation: CalculatorOperation) {
        justEvaluated = false
        if !currentEntry.isEmpty {
            commitCurrentEntry()
            tokens.append(.op(operation))
            return
        }
        if case .op = tokens.last {
            tokens[tokens.count - 1] = .op(operation)
            return
        }
        if case .openParen = tokens.last, operation == .subtract {
            currentEntry = "-"
            return
        }
        if tokens.isEmpty {
            if operation == .subtract {
                currentEntry = "-"
            }
            return
        }
        tokens.append(.op(operation))
    }

    // MARK: - Parentheses

    private func openParen() {
        if justEvaluated {
            tokens = []
            currentEntry = ""
            justEvaluated = false
        }
        if !currentEntry.isEmpty {
            commitCurrentEntry()
            tokens.append(.op(.multiply))
        } else if isImplicitMultiplyTarget(tokens.last) {
            tokens.append(.op(.multiply))
        }
        tokens.append(.openParen)
    }

    private func closeParen() {
        let openCount = tokens.filter { if case .openParen = $0 { return true }; return false }.count
        let closeCount = tokens.filter { if case .closeParen = $0 { return true }; return false }.count
        guard openCount > closeCount else { return }
        guard !currentEntry.isEmpty || isImplicitMultiplyTarget(tokens.last) else { return }
        commitCurrentEntry()
        tokens.append(.closeParen)
    }

    private func isImplicitMultiplyTarget(_ token: Token?) -> Bool {
        switch token {
        case .number, .closeParen: return true
        default: return false
        }
    }

    // MARK: - Scientific functions

    private func applyScientific(_ function: ScientificFunction) {
        let raw = currentEntry.isEmpty ? display : currentEntry
        guard let value = Double(raw) else { return }
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
        }
        currentEntry = format(result)
        display = currentEntry
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

    // MARK: - Evaluation

    private func evaluateAll() {
        commitCurrentEntry()
        let closed = autoClosed(tokens)
        guard let result = evaluateExpression(closed) else {
            display = "Error"
            tokens = []
            currentEntry = ""
            justEvaluated = true
            return
        }
        display = format(result)
        tokens = []
        currentEntry = format(result)
        justEvaluated = true
    }

    private func commitCurrentEntry() {
        guard !currentEntry.isEmpty else { return }
        let value = Double(currentEntry) ?? 0
        tokens.append(.number(value, currentEntry))
        currentEntry = ""
    }

    private func autoClosed(_ tokens: [Token]) -> [Token] {
        let openCount = tokens.filter { if case .openParen = $0 { return true }; return false }.count
        let closeCount = tokens.filter { if case .closeParen = $0 { return true }; return false }.count
        guard openCount > closeCount else { return tokens }
        return tokens + Array(repeating: Token.closeParen, count: openCount - closeCount)
    }

    /// Recursive-descent parser: + − (lowest) -> × ÷ mod -> ^ (right-assoc) -> unary − -> parens/number.
    private func evaluateExpression(_ tokens: [Token]) -> Double? {
        var pos = 0

        func peek() -> Token? { pos < tokens.count ? tokens[pos] : nil }

        func parseExpression() -> Double? {
            guard var left = parseTerm() else { return nil }
            while let token = peek(), case .op(let o) = token, o == .add || o == .subtract {
                pos += 1
                guard let right = parseTerm() else { return nil }
                left = (o == .add) ? left + right : left - right
            }
            return left
        }

        func parseTerm() -> Double? {
            guard var left = parsePower() else { return nil }
            while let token = peek(), case .op(let o) = token, o == .multiply || o == .divide || o == .mod {
                pos += 1
                guard let right = parsePower() else { return nil }
                switch o {
                case .multiply: left *= right
                case .divide: left = (right == 0) ? .nan : left / right
                case .mod: left = left.truncatingRemainder(dividingBy: right)
                default: break
                }
            }
            return left
        }

        func parsePower() -> Double? {
            guard let base = parseUnary() else { return nil }
            if let token = peek(), case .op(let o) = token, o == .power {
                pos += 1
                guard let exponent = parsePower() else { return nil }
                return pow(base, exponent)
            }
            return base
        }

        func parseUnary() -> Double? {
            if let token = peek(), case .op(let o) = token, o == .subtract {
                pos += 1
                guard let value = parseUnary() else { return nil }
                return -value
            }
            return parsePrimary()
        }

        func parsePrimary() -> Double? {
            guard let token = peek() else { return nil }
            pos += 1
            switch token {
            case .number(let value, _):
                return value
            case .openParen:
                guard let value = parseExpression() else { return nil }
                guard case .closeParen = peek() else { return nil }
                pos += 1
                return value
            default:
                return nil
            }
        }

        guard let result = parseExpression(), pos == tokens.count else { return nil }
        return result
    }

    // MARK: - Live preview

    private func updatePreview() {
        var parts = tokens.map { $0.displayString }
        if !currentEntry.isEmpty { parts.append(currentEntry) }
        expressionPreview = parts.joined(separator: " ")

        var previewTokens = tokens
        if !currentEntry.isEmpty, let value = Double(currentEntry) {
            previewTokens.append(.number(value, currentEntry))
        }
        while case .op = previewTokens.last {
            previewTokens.removeLast()
        }
        let hasOperator = previewTokens.contains { if case .op = $0 { return true }; return false }
        guard hasOperator, !previewTokens.isEmpty else {
            resultPreview = ""
            return
        }
        guard let result = evaluateExpression(autoClosed(previewTokens)) else {
            resultPreview = ""
            return
        }
        resultPreview = "= " + format(result)
    }

    // MARK: - Formatting

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
