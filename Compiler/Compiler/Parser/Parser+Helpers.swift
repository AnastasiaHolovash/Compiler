//
//  Parser+Helpers.swift
//  Compiler
//
//  Created by Головаш Анастасия on 11.10.2020.
//

import Foundation

extension Parser {
    
    func check(token: Token) throws {
        
        guard canGet, case token = getNextToken() else {
            var sign = ""
            switch token {
            case .curlyOpen:
                sign = "{"
            case .curlyClose:
                sign = "}"
            case .parensOpen:
                sign = "("
            case .parensClose:
                sign = ")"
            case .equal:
                sign = "="
            case .semicolon:
                sign = ";"
            case .return:
                sign = "\'return\' in function bloc"
            case .if:
                sign = "\'if\'"
            case .else:
                sign = "\'else\'"
            case .comma:
                sign = "\',\'"
            case .break:
                sign = "\'break\'"
            case .continue:
                sign = "\'continue\'"
            default:
                throw Error.unexpectedError
            }
            throw Error.expected(sign, position: getTokenPositionInCode())
        }
        
    }
    
}
