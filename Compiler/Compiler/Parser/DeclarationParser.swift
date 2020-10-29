//
//  DeclarationParser.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation

extension Parser {
    
    // MARK: - Declaration
    func declarationParser() throws -> ASTnode {
    
        var returnType : Token
        let returnTypePopToken = getNextToken()
        
        // Return Type
        if case .int = returnTypePopToken {
            returnType = Token.int
        } else if case .float = returnTypePopToken {
            returnType = Token.float
        } else {
            throw Error.expected("function return type", position: getTokenPositionInCode())
        }
        
        // Identifier
        guard case let .identifier(identifier) = getNextToken() else {
            throw Error.expectedIdentifier(position: getTokenPositionInCode())
        }
        
        // Function or Variable
        if case .parensOpen = peek().token {
            return try functionParser(returnType: returnType, identifier: identifier)
        } else if peek().token == Token.equal || peek().token  == Token.semicolon {
            return try variableDeclarationParser(returnType: returnType, identifier: identifier)
        } else {
            throw Error.incorrectDeclaration(position: tokensStruct[index].position)
        }
        
    }
    
    
    // MARK: - Function Declaration
    func functionParser(returnType: Token, identifier: String) throws -> ASTnode {
        try check(token: .parensOpen)
        try check(token: .parensClose)
        let codeBlock = try codeBlockParser()
        
        if let codeBlock = codeBlock as? CodeBlock {
            if !(codeBlock.astNodes.last is ReturnStatement) {
                throw Error.expected("return", position: getTokenPositionInCode())
            }
        }
        
        return Function(returnType: returnType, identifier: identifier,
                                  block: codeBlock)
    }
    
    
    // MARK: - Variable Declaration
    func variableDeclarationParser(returnType: Token, identifier: String) throws -> ASTnode {
        
        // If it goes semicolon after identifier
        guard canGet, case .equal = peek().token else {
            try check(token: .semicolon)
            // If not exist in curent block
            if identifiers[blockDepth]?[identifier] != nil {
                throw Error.variableAlreadyExist(identifier, position: getTokenPositionInCode())
            }
            identifiers[blockDepth]?[identifier] = getNextAdres()
            return Variable(identifier: Identifier(name: identifier, position: adres), value: nil)
        }
        
        // If it goes equal after identifier
        try check(token: .equal)
        let expression = try parseExpression()
        try check(token: .semicolon)
        // If not exist in curent block
        if identifiers[blockDepth]?[identifier] != nil {
            throw Error.variableAlreadyExist(identifier, position: getTokenPositionInCode())
        }
        identifiers[blockDepth]?[identifier] = getNextAdres()
        return Variable(identifier: Identifier(name: identifier, position: adres), value: expression)
    }
    
    
    // MARK: - Identifier
    func identifierParser(position: Int) throws -> ASTnode {
        guard case let .identifier(name) = getNextToken() else {
            throw Error.expectedIdentifier(position: getTokenPositionInCode())
        }
        return Identifier(name: name, position: position)
    }
    
}
