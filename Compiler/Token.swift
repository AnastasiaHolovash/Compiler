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

// MARK: - Token
enum Token {
    
    case minusOp
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
    
    static var tokenGeter: [String : (String) -> Token?] {
        return [
            "^(^0[xX][0-9a-fA-F]+)|^(^[0-9]+\\.[0-9]+)|^([0-9]+)": {
                print($0)
                if $0.contains(".") {
                    return .numberFloat(Float($0)!)
                } else if $0.contains("x") || $0.contains("X") {
                    let some = $0.hexToDec()
                    print(some)
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
                return .identifier($0)
            },
            "\\-": { _ in .minusOp },
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
