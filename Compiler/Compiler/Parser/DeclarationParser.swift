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

        guard canGet, case let .type(returnType) = getNextToken() else {
            throw Error.expected("function return type", position: getTokenPositionInCode())
        }
        
        // Identifier
        guard case let .identifier(identifier) = getNextToken() else {
            throw Error.expectedIdentifier(position: getTokenPositionInCode())
        }
        
        // Function or Variable
        if case .parensOpen = peek().token {
            return try functionDefinitionParser(returnType: returnType, identifier: identifier)
        } else if peek().token == Token.equal || peek().token  == Token.semicolon {
            return try variableDeclarationParser(returnType: returnType, identifier: identifier)
        } else {
            throw Error.incorrectDeclaration(position: tokensStruct[index].position)
        }
        
    }

    
    // MARK: - Function Arguments
    func functionArgumentsParser() throws -> [Argument] {
        var args: [Argument] = []
        
        try check(token: .parensOpen)
        while .parensClose != peek().token {
            guard case let .identifier(identifier) = getNextToken() else {
                throw Error.expectedIdentifier(position: getTokenPositionInCode())
            }
            guard case let .type(type) = getNextToken() else {
                throw Error.expected("type", position: getTokenPositionInCode())
            }
            if .comma != peek().token {
                if .parensClose != peek().token {
                    try check(token: .comma)
                }
            } else {
                try check(token: .comma)
            }
            args.append(Argument(name: identifier, type: type))
        }
        try check(token: .parensClose)
        
        return args
    }
    
    
    // MARK: - Function Definition
    func functionDefinitionParser(returnType: Type, identifier: String) throws -> ASTnode {
    
        let args = try functionArgumentsParser()
        let funcIdentifier = FunctionIdentifier(type: returnType, name: identifier, arguments: args)
        
        if .semicolon == peek().token {
            try check(token: .semicolon)
            
            Parser.functionDeclaredIdentifiers.append(funcIdentifier)
            return funcIdentifier
        } else {
            let codeBlock = try codeBlockParser()
            
            if let codeBlock = codeBlock as? CodeBlock {
                if !(codeBlock.astNodes.last is ReturnStatement) {
                    throw Error.expected("return", position: getTokenPositionInCode())
                }
            }
            
            Parser.functionDeclaredIdentifiers.append(funcIdentifier)
            Parser.functionDefinedIdentifiers.append(funcIdentifier)
            return Function(returnType: returnType, arguments: args, identifier: identifier,
                                      block: codeBlock)
        }
    }
    
    
    // MARK: - Variable Declaration
    func variableDeclarationParser(returnType: Type, identifier: String) throws -> ASTnode {
        
        // If it goes semicolon after identifier
        guard canGet, case .equal = peek().token else {
            try check(token: .semicolon)
            // If not exist in curent block
            if Parser.variablesIdentifiers[blockDepth]?[identifier] != nil {
                throw Error.variableAlreadyExist(identifier, position: getTokenPositionInCode())
            }
            Parser.variablesIdentifiers[blockDepth]?[identifier] = Parser.getNextAdres()
            return Variable(identifier: VariableIdentifier(name: identifier, position: Parser.adres), value: nil)
        }
        
        // If it goes equal after identifier
        try check(token: .equal)
        let expression = try parseExpression()
        try check(token: .semicolon)
        
        // If not exist in curent block
        if Parser.variablesIdentifiers[blockDepth]?[identifier] != nil {
            throw Error.variableAlreadyExist(identifier, position: getTokenPositionInCode())
        }
        Parser.variablesIdentifiers[blockDepth]?[identifier] = Parser.getNextAdres()
        return Variable(identifier: VariableIdentifier(name: identifier, position: Parser.adres), value: expression)
    }
    
    
    // MARK: - Identifier
    func identifierParser(position: Int) throws -> ASTnode {
        guard case let .identifier(name) = getNextToken() else {
            throw Error.expectedIdentifier(position: getTokenPositionInCode())
        }
        return VariableIdentifier(name: name, position: position)
    }
    
}
