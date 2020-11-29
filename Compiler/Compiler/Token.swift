//
//  Token.swift
//  Compiler
//
//  Created by Головаш Анастасия on 25.10.2020.
//

import Foundation


struct TokenStruct {
    let token: Token
    let position: (line: Int, place: Int)
}


protocol ThrowCastingError {
    func throwCastingError() throws
    func unknownOperation(op: String) throws
}


// MARK: - Token
enum Token: Equatable {
    
    case numberFloat(Float)
    case numberInt(Int, NunberType)
    case type(Type)
    case identifier(String)
    case parensOpen
    case parensClose
    case `return`
    case curlyOpen
    case curlyClose
    case semicolon
    // Lab 2 edition
    case operation(Operator)
    // Lab 3 edition
    case equal
    // Lab 4 edition
    case `if`
    case `else`
    // Lab 5 edition
    case comma
    // Lab 6 edition
    case `while`
    case `break`
    case `continue`
    // Cousework
    case comment

    
    static var delegate : ThrowCastingError?
    
    static var tokenGeter: [String : (String) throws -> Token?] {
        return [
            "^(^0[xX][0-9a-fA-F]+)|^(^[0-9]+\\.[0-9]+)|^([0-9]+)": {
                if $0.contains(".") {
                    guard let num = Float($0) else {
                        try delegate?.throwCastingError()
                        throw Parser.Error.unexpectedError
                    }
                    return .numberFloat(num)
                } else if $0.contains("x") || $0.contains("X") {
                    let some = $0.hexToDec()
                    return .numberInt(Int(some), .hex)
                } else {
                    return .numberInt(Int($0)!, .decimal)
                }
            },
            
            "[a-zA-Z_$][a-zA-Z_$0-9]*": {
                guard $0 != "int" else {
                    return .type(.int)
                }
                guard $0 != "float" else {
                    return .type(.float)
                }
                guard $0 != "return" else {
                    return .return
                }
                guard $0 != "if" else {
                    return .if
                }
                guard $0 != "else" else {
                    return .else
                }
                guard $0 != "while" else {
                    return .while
                }
                guard $0 != "break" else {
                    return .break
                }
                guard $0 != "continue" else {
                    return .continue
                }
                return .identifier($0)
            },
            
            "(\\/\\/.*)|\\/\\=|\\*|\\/|\\%|\\+|\\-|\\<": {
                if $0.hasPrefix("//") || ($0.hasPrefix("/*") && $0.hasSuffix("*/")) {
                    return .comment
                } else if $0 == "/" {
                    return .operation(Operator(rawValue: $0)!)
                } else if $0 == "*" {
                    return .operation(Operator(rawValue: $0)!)
                } else if $0 == "<" {
                    return .operation(Operator(rawValue: $0)!)
                } else if $0 == "-" {
                    return .operation(Operator(rawValue: $0)!)
                } else if $0 == "/=" {
                    return .operation(Operator(rawValue: $0)!)
                } else if $0 == "%" {
                    return .operation(Operator(rawValue: $0)!)
                } else {
                    try delegate?.unknownOperation(op: $0)
                    throw Parser.Error.unexpectedError
                }
            },
            
            "\\=": { _ in .equal },
            "\\(": { _ in .parensOpen },
            "\\)": { _ in .parensClose },
            "\\{": { _ in .curlyOpen },
            "\\}": { _ in .curlyClose },
            "\\;": { _ in .semicolon },
            "\\,": { _ in .comma }
        ]
    }
}

// MARK: - Type
enum Type {
    case int
    case float
}


// MARK: - Nunber Type
enum NunberType {
    case decimal
    case hex
}


// MARK: - Binary Operator
enum Operator: String {
    
    case divide = "/"
    case multiply = "*"
    case isLessThan = "<"
    case divideEqual = "/="
    case remainderAfterDivision = "%"
    case minus = "-"
    
    var precedence: Int {
        switch self {
        case .divide:
            return 40
        case .multiply:
            return 40
        case .isLessThan:
            return 20
        case .divideEqual:
            return 10
        case .remainderAfterDivision:
            return 40
        case .minus:
            return 30
        }
    }
}
