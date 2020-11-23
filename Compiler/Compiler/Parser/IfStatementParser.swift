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
        guard blockDepth > 0 else {
            throw Error.ifStatementInGlobalScope(position: getTokenNextPositionInCode())
        }
        
        try check(token: .if)
        try check(token: .parensOpen)
        let expression = try parseExpression()
        try check(token: .parensClose)
        
        
        if canGet {
            var firstBlock = try extensionBlockParser()
            
//            if var firstBlockBlock = firstBlock as? CodeBlock {
//                firstBlockBlock.type = " if"
//                firstBlock = firstBlockBlock
//            } else if var firstBlockBlock = firstBlock as? ReturnStatement {
//                firstBlockBlock.type = " if"
//                firstBlock = firstBlockBlock
//            } else if var firstBlockBlock = firstBlock as? FunctionCall {
//                firstBlockBlock.type = " if"
//                firstBlock = firstBlockBlock
//            } else if var firstBlockBlock = firstBlock as? Variable {
//                firstBlockBlock.type = " if"
//                firstBlock = firstBlockBlock
//            }
            addMarker(block: &firstBlock, type: " if")
            
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
            
//            if var secondBlockBlock = secondBlock as? CodeBlock {
//                secondBlockBlock.type = " else"
//                secondBlock = secondBlockBlock
//            }
            addMarker(block: &secondBlock, type: " else")
            
            return IfStatement(condition: expression, ifBlock: firstBlock, elseBlock: secondBlock)
            
        }
        throw Error.incorrectIfStatement(position: getTokenPositionInCode())
    }
    
    func addMarker(block: inout ASTnode, type: String) {
        if var blockBlock = block as? CodeBlock {
            blockBlock.type = type
            block = blockBlock
        } else if var blockBlock = block as? ReturnStatement {
            blockBlock.type = type
            block = blockBlock
        } else if var blockBlock = block as? FunctionCall {
            blockBlock.type = type
            block = blockBlock
        } else if var blockBlock = block as? Variable {
            blockBlock.type = type
            block = blockBlock
        }
    }
}
