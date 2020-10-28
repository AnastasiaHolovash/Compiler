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
    case numberInt(Int, Type)
    case int
    case float
    case identifier(String)
    case parensOpen
    case parensClose
    case `return`
    case curlyOpen
    case curlyClose
    case semicolon
    // Lab 2 edition
    case unaryOperation(UnaryOperator)
    case binaryOperation(BinaryOperator)
    // Lab 3 edition
    case equal
    // Lab 4 edition
    case `if`
    case `else`
    
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
                    return .int
                }
                guard $0 != "float" else {
                    return .float
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
                return .identifier($0)
            },
            
            "\\*|\\/|\\+|\\-|\\<": {
                if $0 == "/" {
                    return .binaryOperation(BinaryOperator(rawValue: $0)!)
                } else if $0 == "*" {
                    return .binaryOperation(BinaryOperator(rawValue: $0)!)
                } else if $0 == "<" {
                    return .binaryOperation(BinaryOperator(rawValue: $0)!)
                } else if $0 == "-" {
                    return .unaryOperation(UnaryOperator(rawValue: $0)!)
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
            "\\;": { _ in .semicolon }
        ]
    }
}


// MARK: - Type
enum Type {
    case decimal
    case hex
}


// MARK: - Binary Operator
enum BinaryOperator: String {
    
    case divide = "/"
    case multiply = "*"
    case isLessThan = "<"
    
    var precedence: Int {
        switch self {
        case .divide:
            return 20
        case .multiply:
            return 20
        case .isLessThan:
            return 10
        }
    }
}


// MARK: - Unary Operator
enum UnaryOperator: String {

    case minus = "-"
    
    var precedence: Int {
        switch self {
        case .minus:
            return 30
        }
    }
}