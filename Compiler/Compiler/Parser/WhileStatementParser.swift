//
//  WhileStatementParser.swift
//  Compiler
//
//  Created by Anastasia Holovash on 15.11.2020.
//

import Foundation

extension Parser {
    
    // MARK: - While statement
    func whileStatementParser() throws -> ASTnode {
        try check(token: .while)
        try check(token: .parensOpen)
        let expression = try parseExpression()
        try check(token: .parensClose)
        let block = try extensionBlockParser(canBreak: true)
        
        return WhileStatement(condition: expression, block: block)
    }
        

    /**
     Extension Block Parser
     
     - parameter canBreak: True if block can be breaked or continued, false - if not.
     
     This func checks if next is:
        - return statement;
        -  or function call;
        - or variable overriding;
        - or code block;
    
     and parse that.
     */
    func extensionBlockParser(canBreak: Bool = false) throws -> ASTnode {
        switch peek().token {
        case .return:
            return try returningParser()
        case .identifier:
            if case .parensOpen = peekThroughOne().token {
                let functionCall =  try functionCallParser()
                try check(token: .semicolon)
                return functionCall
            } else {
                return try variableOverridingParser()
            }
        default:
            return try codeBlockParser(canBreak: canBreak)
        }
    }
    
    
    func breakParser() throws -> ASTnode {
        guard canBreak else {
            throw Error.foundBreakOutsideTheLoop(position: getTokenNextPositionInCode())
        }
        try check(token: .break)
        try check(token: .semicolon)
        return Break()
    }

    
    func continueParser() throws -> ASTnode {
        guard canBreak else {
            throw Error.foundContinueOutsideTheLoop(position: getTokenNextPositionInCode())
        }
        try check(token: .continue)
        try check(token: .semicolon)
        return Continue()
    }
}
