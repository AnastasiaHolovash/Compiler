//
//  Token.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

struct TokenStruct {
    let token: Token
    let position: (line: Int, place: Int)
}

protocol ThrowCastingError {
    func throwCastingError() throws
    func printingCastingPosition()
}

// MARK: - Token
enum Token {
    
    case minusOperation
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
    
    static var delegate : ThrowCastingError?
    
    static var tokenGeter: [String : (String) throws -> Token?] {
        return [
            "^(^0[xX][0-9a-fA-F]+)|^(^[0-9]+\\.[0-9]+)|^([0-9]+)": {
                if $0.contains(".") {
                    guard let num = Float($0) else {
                        try delegate?.throwCastingError()
                        fatalError("Not float")
                    }
                    delegate?.printingCastingPosition()
                    return .numberFloat(num)
                } else if $0.contains("x") || $0.contains("X") {
                    let some = $0.hexToDec()
                    delegate?.printingCastingPosition()
                    return .numberInt(Int(some), .hex)
                } else {
                    delegate?.printingCastingPosition()
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
                return .identifier($0)
            },
            
            "\\-": { _ in .minusOperation },
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
