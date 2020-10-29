//
//  IfStatementParser.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation

extension Parser {
    
    // MARK: - If statement
    func ifStatementParser() throws -> ASTnode {
        try check(token: .if)
        try check(token: .parensOpen)
        let expression = try parseExpression()
        try check(token: .parensClose)
        
        // TODO: - code block or expresion
        if canGet {
            switch peek().token {
            case .return:
                let statement = try returningParser()
                return IfStatement(condition: expression, ifBlock: statement, elseBlock: nil)
            case .identifier:
                let statement = try variableOverridingParser()
                return IfStatement(condition: expression, ifBlock: statement, elseBlock: nil)
            default:
                // if-block parsing
                guard var firstBlock = try codeBlockParser() as? CodeBlock else {
                    throw Parser.Error.expected("Code block", position: getTokenPositionInCode())
                }
                firstBlock.type = " if"
                
                // if else-block exist
                if canGet, case .else = peek().token {
                    try check(token: .else)
                    
                    // [ else if(){} ] construction converting to [ else { if(){} } ]
                    if canGet, case .if = peek().token {
                        let secondBlock = try ifStatementParser()
                        return IfStatement(condition: expression, ifBlock: firstBlock, elseBlock: secondBlock)
                    }
                    
                    guard var secondBlock = try codeBlockParser() as? CodeBlock else {
                        throw Parser.Error.expected("Code block", position: getTokenPositionInCode())
                    }
                    secondBlock.type = " else"
                    return IfStatement(condition: expression, ifBlock: firstBlock, elseBlock: secondBlock)
                } else {
                    return IfStatement(condition: expression, ifBlock: firstBlock, elseBlock: nil)
                }
            }
        }
        throw Error.incorrectIfStatement(position: getTokenPositionInCode())
    }
    
}
