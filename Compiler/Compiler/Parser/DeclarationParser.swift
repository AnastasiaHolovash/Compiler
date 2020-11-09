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
            return try functionParser(returnType: returnType, identifier: identifier)
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
            guard case let .type(type) = getNextToken() else {
                throw Error.expected("type", position: getTokenPositionInCode())
            }
            guard case let .identifier(identifier) = getNextToken() else {
                throw Error.expectedIdentifier(position: getTokenPositionInCode())
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
    
    
    // MARK: - Function
    func functionParser(returnType: Type, identifier: String) throws -> ASTnode {
    
        let args = try functionArgumentsParser()
        let funcIdentifier = FunctionIdentifier(type: returnType, name: identifier, arguments: args)
        
        // Declaration
        if .semicolon == peek().token {
            try check(token: .semicolon)
            
            // Chacking if func was Declare, if YES - with the same args
            try chackIfFuncWasDeclare(funcIdentifier: funcIdentifier)
            
            // Append funcIdentifier to functionDeclaredIdentifiers with blockDepth
            var array = Parser.functionDeclaredIdentifiers[blockDepth]
            array?.append(funcIdentifier)
            Parser.functionDeclaredIdentifiers[blockDepth] = array
            
            return funcIdentifier
        } else {
            // Definition
            
            // Chacking if func was Define
            for item in Parser.functionDefinedIdentifiers {
                if identifier == item.name {
                    throw Error.functionWasDefineBefore(identifier, position: getTokenPositionInCode())
                }
            }
            // Chacking if func was Declare, if YES - with the same args
            try chackIfFuncWasDeclare(funcIdentifier: funcIdentifier)
            
            let codeBlock = try codeBlockParser()
            
            if let codeBlock = codeBlock as? CodeBlock {
                if !(codeBlock.astNodes.last is ReturnStatement) {
                    throw Error.expected("return", position: getTokenPositionInCode())
                }
            }
            
            // Append funcIdentifier to functionDeclaredIdentifiers with blockDepth
            var array = Parser.functionDeclaredIdentifiers[blockDepth]
            array?.append(funcIdentifier)
            Parser.functionDeclaredIdentifiers[blockDepth] = array
            
            Parser.functionDefinedIdentifiers.append(funcIdentifier)
            return Function(returnType: returnType, arguments: args, identifier: identifier,
                                      block: codeBlock)
        }
    }
    
    
    /**
     Chacking if func was Declare, if YES - with the same return type,  with the same args.
     */
    func chackIfFuncWasDeclare(funcIdentifier: FunctionIdentifier) throws {
        for arr in Parser.functionDeclaredIdentifiers.values {
            for item in arr {
                // If func was Declare
                if funcIdentifier.name == item.name{
                    // with other return type
                    guard funcIdentifier.type == item.type else {
                        throw Error.conflictingReturnTypesFor(funcIdentifier.name, previousDeclaration: item.getDeclarString(), position: getTokenPositionInCode())
                    }
                    // with other args
                    guard funcIdentifier.arguments == item.arguments else {
                        throw Error.conflictingArgumentsTypesFor(funcIdentifier.name, previousDeclaration: item.getDeclarString(), position: getTokenPositionInCode())
                    }
                }
            }
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
    func variableIdentifierParser() throws -> ASTnode {
        
        guard case let .identifier(name) = getNextToken() else {
            throw Error.expectedIdentifier(position: getTokenPositionInCode())
        }
        
        // Checking if identifier was declared
        for value in stride(from: blockDepth, through: 1, by: -1) {
            if let position = Parser.variablesIdentifiers[value]?[name] {
                return VariableIdentifier(name: name, position: position)
            }
        }
        throw Error.noSuchIdentifier(name, position: getTokenPositionInCode())
    }
    
    
    // MARK: - Identifier
    func functionCallParser() throws -> ASTnode {
        var args: [ASTnode] = []
        guard case let .identifier(name) = getNextToken() else {
            throw Error.expectedIdentifier(position: getTokenPositionInCode())
        }
        let namePosition = getTokenPositionInCode()
        
        try check(token: .parensOpen)
        while .parensClose != peek().token {
            let expresion = try parseExpression()
            if .comma != peek().token {
                if .parensClose != peek().token {
                    try check(token: .comma)
                }
            } else {
                try check(token: .comma)
            }
            args.append(expresion)
        }
        try check(token: .parensClose)
        
        for arr in Parser.functionDeclaredIdentifiers.values {
            for item in arr {
                if name == item.name {
                    if args.count == item.arguments.count {
                        Parser.functionCalledIdentifiers.append((item, namePosition))
                        return FunctionCall(name: name, arguments: args)
                    }
                    throw Error.invalidFunctionCall(position: getTokenPositionInCode())
                }
            }
        }
        throw Error.functionWasntDeclar(name, position: namePosition)
    }
}
