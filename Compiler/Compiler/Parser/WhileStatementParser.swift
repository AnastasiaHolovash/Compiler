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
        let block = try extensionBlockParser()
        
        return WhileStatement(condition: expression, block: block)
    }
        


    func extensionBlockParser() throws -> ASTnode {
        switch peek().token {
        case .return:
            return try returningParser()
        case .identifier:
            if case .parensOpen = peekThroughOne().token {
                return try functionCallParser()
                try check(token: .semicolon)
            } else {
                return try variableOverridingParser()
            }
        default:
            return try codeBlockParser()
        }
    }

}
