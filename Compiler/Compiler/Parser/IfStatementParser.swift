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
        
        
        if canGet {
            var firstBlock = try extensionBlockParser()
            
            if var firstBlockBlock = firstBlock as? CodeBlock {
                firstBlockBlock.type = " if"
                firstBlock = firstBlockBlock
            }
            
            // If else-block exist
            guard canGet, case .else = peek().token else {
                return IfStatement(condition: expression, ifBlock: firstBlock, elseBlock: nil)
            }
            try check(token: .else)
            
            var secondBlock: ASTnode
            
            // [ else if(){} ] construction converting to [ else { if(){} } ]
            if canGet, case .if = peek().token {
                secondBlock = try ifStatementParser()
                return IfStatement(condition: expression, ifBlock: firstBlock, elseBlock: secondBlock)
            }
            
            secondBlock = try extensionBlockParser()
            
            if var secondBlockBlock = secondBlock as? CodeBlock {
                secondBlockBlock.type = " else"
                secondBlock = secondBlockBlock
            }
            
            return IfStatement(condition: expression, ifBlock: firstBlock, elseBlock: secondBlock)
            
        }
        throw Error.incorrectIfStatement(position: getTokenPositionInCode())
    }
}
