//
//  Parser.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

protocol ASTnode: PrintableTreeNode {
    func generatingAsmCode() throws -> String
}

// MARK: - PARSER
class Parser {
    
    /// List of tokens with.
    let tokensStruct: [TokenStruct]
    
    var blockDepth: Int
    
    init(tokensStruct: [TokenStruct], blockDepth: Int = 0) {
        self.tokensStruct = tokensStruct
        self.blockDepth = blockDepth
    }
    
    /// Current location of the parsing phase
    var index = 0
    
    
    var canGet: Bool {
        return index < tokensStruct.count ? true : false
    }

    
    /**
     A way of checking the element at the current location without incrementing the index.
     
    To check WITH incrementing the index use getNextToken().
     */
    func peek() -> TokenStruct {
        return tokensStruct[index]
    }
    
    
    /**
     A way of checking the element at the current location, but ultimately incrementing the index.
     
    To check WITHOUT incrementing the index use peek().
     */
    func getNextToken() -> Token {
        let token = tokensStruct[index].token
        index += 1
        return token
    }
    
    
    // MARK: - Code block
    func codeBlockParser() throws -> ASTnode {
        
        try check(token: .curlyOpen)
        
//        depth = 1
        var depth = 1
        let startIndex = index
        
        while canGet {
            guard case .curlyClose = peek().token else {
                if case .curlyOpen = peek().token {
                    depth += 1
                }
                index += 1
                continue
            }
            
            depth -= 1

            guard depth == 0 else {
                index += 1
                continue
            }
            break
        }
        
        let endIndex = index

        try check(token: .curlyClose)
        let tokens = Array(self.tokensStruct[startIndex..<endIndex])
        identifiers[blockDepth + 1] = [:]
        return try Parser(tokensStruct: tokens, blockDepth: blockDepth + 1).parse()
    }
    
    
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
    
    
    // MARK: - Function
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
    
    
    // MARK: - Variable Overriding
    func variableOverridingParser() throws -> ASTnode {
        
        // Geting identifier
        guard case let .identifier(identifier) = getNextToken() else {
            throw Error.expectedIdentifier(position: getTokenPositionInCode())
        }
        
        // Checking if identifier was declared
        for value in stride(from: blockDepth, through: 1, by: -1) {
            if let position = identifiers[value]?[identifier] {
                try check(token: .equal)
                let expression = try parseExpression()
                try check(token: .semicolon)
                
                return Variable(identifier: Identifier(name: identifier, position: position), value: expression)
            }
        }
        throw Error.noSuchIdentifier(identifier, position: getTokenPositionInCode())

    }
    
    
    // MARK: - Returning
    func returningParser() throws -> ASTnode {
        var node: ASTnode
        try check(token: .return)
        node = try parseExpression()
        try check(token: .semicolon)
        
        return ReturnStatement(node: node)
    }
    
    
    // MARK:- parens ()
    func parensParser() throws -> ASTnode {
        try check(token: .parensOpen)
        let expressionNode = try parseExpression()
        try check(token: .parensClose)
        
        return expressionNode
    }
    
    
    // MARK: - Expression
    func parseExpression() throws -> ASTnode {
        guard canGet else {
            throw Error.expectedExpression(position: getTokenPositionInCode())
        }
        let node = try valueParser()
        
        return try infixOperationParser(node: node)
    }
    
    
    // MARK: - Value
    func valueParser() throws -> ASTnode {
        switch (peek().token) {
        case .numberInt:
            return try intNumberParser()
        case .numberFloat:
            return try floatNumberParser()
        case .parensOpen:
            return try parensParser()
        case .unaryOperation:
            if case .unaryOperation(_) = tokensStruct[index - 1].token {
                let (line, place) = tokensStruct[index].position
                throw Error.expectedNumber(position: (line: line, place: place))
            }
            return try prefixOperationParser()
        case let .identifier(identifier):
            
            // Checking if identifier was declared
            for value in stride(from: blockDepth, through: 1, by: -1) {
                if let position = identifiers[value]?[identifier] {
                    return try identifierParser(position: position)
                }
            }
//            if identifiers[str] == nil {
                throw Error.noSuchIdentifier(identifier, position: getTokenPositionInCode())
//            }
//            return try identifierParser()
        default:
            let (line, place) = tokensStruct[index].position
            throw Error.expectedNumber(position:(line: line, place: place))
        }
    }
    
    
    // MARK: - Peek Precedence
    func peekPrecedence() throws -> Int {
        if canGet {
            switch peek().token {
            case .binaryOperation(let op):
                return op.precedence
            case .unaryOperation(let op):
                return op.precedence
            default:
                return -1
            }
        } else {
            return -1
        }
    }
       
    
    // MARK: - Infix Operation
    func infixOperationParser(node: ASTnode, nodePrecedence: Int = 0) throws -> ASTnode {
        var leftNode = node
        var precedence = try peekPrecedence()
        
        while precedence >= nodePrecedence {
            guard case let .binaryOperation(op) = getNextToken() else {
                throw Error.expected("binary operation", position: getTokenPositionInCode())
            }
            var rightNode = try valueParser()
            let nextPrecedence = try peekPrecedence()
            
            // if next operstion with higher priority
            if precedence < nextPrecedence {
                
                // rightNode become leftNode for operation with higher priority
                rightNode = try infixOperationParser(node: rightNode, nodePrecedence: precedence + 1)
            }
            leftNode = InfixOperation(operation: op, leftNode: leftNode, rightNode: rightNode)
            precedence = try peekPrecedence()
        }
        return leftNode
    }
        
    
    // MARK: - Prefix Operation
    func prefixOperationParser() throws -> ASTnode {

        guard case let .unaryOperation(op) = getNextToken() else {
            throw Error.expected("-", position: getTokenPositionInCode())
        }
        
        let rightNode = try valueParser()

        return PrefixOperation(operation: op, item: rightNode)
    }

    
    // MARK: - Float
    func floatNumberParser() throws -> ASTnode {
        guard case .numberFloat(_) = getNextToken() else {
            throw Error.expectedNumber(position: getTokenPositionInCode())
        }
        return Number(number: tokensStruct[index - 1])
    }
    
    
    // MARK: - Int
    func intNumberParser() throws -> ASTnode {
        guard case .numberInt(_, _) = getNextToken() else {
            throw Error.expectedNumber(position: getTokenPositionInCode())
        }
        return Number(number: tokensStruct[index - 1])
    }
    
    
    // MARK: - Identifier
    func identifierParser(position: Int) throws -> ASTnode {
        guard case let .identifier(name) = getNextToken() else {
            throw Error.expectedIdentifier(position: getTokenPositionInCode())
        }
        return Identifier(name: name, position: position)
    }
    
    
    // MARK: - Parse
    func parse() throws -> ASTnode {
        var nodes: [ASTnode] = []
        while canGet {
            let token = peek()
            switch token.token {
            case .return:
                let returning = try returningParser()
                nodes.append(returning)
            case .int, .float:
                let definition = try declarationParser()
                nodes.append(definition)
            case .identifier:
                let overriding = try variableOverridingParser()
                nodes.append(overriding)
            case .if:
                let ifStatement = try ifStatementParser()
                nodes.append(ifStatement)
            case .curlyOpen:
                let block = try codeBlockParser()
                identifiers[blockDepth + 1] = nil
                nodes.append(block)
            default:
                throw Error.unexpectedExpresion(position: token.position)
            }
        }
        return CodeBlock(astNodes: nodes)
    }
    
}
