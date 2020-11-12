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
        
        // code block or expresion
        if canGet {
            var firstBlock: ASTnode
            var secondBlock: ASTnode
            
            switch peek().token {
            case .return:
                firstBlock = try returningParser()
//                return IfStatement(condition: expression, ifBlock: firstBlock, elseBlock: nil)
            case .identifier:
//                statement: ASTnode
                if case .parensOpen = peekThroughOne().token {
                    firstBlock = try functionCallParser()
                    try check(token: .semicolon)
                } else {
                    firstBlock = try variableOverridingParser()
                }
//                return IfStatement(condition: expression, ifBlock: statement, elseBlock: nil)
            default:
                // if-block parsing
                guard var firstBlock1 = try codeBlockParser() as? CodeBlock else {
                    throw Parser.Error.expected("Code block", position: getTokenPositionInCode())
                }
                firstBlock1.type = " if"
                firstBlock = firstBlock1
            }
            
            // if else-block exist
            if canGet, case .else = peek().token {
                try check(token: .else)
                
                // [ else if(){} ] construction converting to [ else { if(){} } ]
                if canGet, case .if = peek().token {
                    secondBlock = try ifStatementParser()
                    return IfStatement(condition: expression, ifBlock: firstBlock, elseBlock: secondBlock)
                }
                
                switch peek().token {
                case .return:
                    let secondBlock = try returningParser()
                    return IfStatement(condition: expression, ifBlock: firstBlock, elseBlock: secondBlock)
                case .identifier:
                    let secondBlock: ASTnode
                    if case .parensOpen = peekThroughOne().token {
                        secondBlock = try functionCallParser()
                        try check(token: .semicolon)
                    } else {
                        secondBlock = try variableOverridingParser()
                    }
                    return IfStatement(condition: expression, ifBlock: firstBlock, elseBlock: secondBlock)
                default:
                    guard var secondBlock = try codeBlockParser() as? CodeBlock else {
                        throw Parser.Error.expected("Code block", position: getTokenPositionInCode())
                    }
                    secondBlock.type = " else"
                    return IfStatement(condition: expression, ifBlock: firstBlock, elseBlock: secondBlock)
                }
                
            } else {
                return IfStatement(condition: expression, ifBlock: firstBlock, elseBlock: nil)
            }
            
        }
        throw Error.incorrectIfStatement(position: getTokenPositionInCode())
    }
    
}
