//
//  ExpressionParser.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation

extension Parser {
    
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
            throw Error.noSuchIdentifier(identifier, position: getTokenPositionInCode())
        default:
            let (line, place) = tokensStruct[index].position
            throw Error.expectedNumber(position:(line: line, place: place))
        }
    }
    
    
    // MARK: - Returning
    func returningParser() throws -> ASTnode {
        var node: ASTnode
        try check(token: .return)
        node = try parseExpression()
        try check(token: .semicolon)
        
        return ReturnStatement(node: node)
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

    
    // MARK:- parens ()
    func parensParser() throws -> ASTnode {
        try check(token: .parensOpen)
        let expressionNode = try parseExpression()
        try check(token: .parensClose)
        
        return expressionNode
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
    
}
