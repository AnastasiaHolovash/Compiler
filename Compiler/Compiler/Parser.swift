//
//  Parser.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

protocol ASTnode {
    func generatingAsmCode() throws -> String
}

// MARK: - PARSER
class Parser {
    
    /// Detection and derivation of Errors
    enum Error: Swift.Error, LocalizedError {
        
        case expectedNumber(Int, Int)
        case expectedIdentifier(Int, Int)
        case expectedExpression(Int, Int)
        case expectedNumberType(String ,Int, Int)
        case expected(String, Int, Int)
        case incorrectDeclaration(Int, Int)
        case noSuchIdentifier(String, Int, Int)
        case unexpectedError
        case unknownOperation
        
        var errorDescription: String? {
            switch self {
            case let .expectedNumber(line, place):
                return """
                        Error: Expected number.
                            Line: \(line)  Place: \(place)
                       """
            case let .expectedIdentifier(line, place):
                return """
                        Error: Expected identifier.
                            Line: \(line)  Place: \(place)
                       """
            case let .expectedExpression(line, place):
                return """
                        Error: Expression expected.
                            Line: \(line)  Place: \(place)
                        """
            case let .expectedNumberType(str, line, place):
                return """
                        Error: Extected number type \(str).
                            Line: \(line)  Place: \(place)
                       """
            case let .expected(str, line, place):
                return """
                        Error: Extected \'\(str)\'.
                            Line: \(line)  Place: \(place)
                       """
            case let .incorrectDeclaration(line, place):
                return """
                        Error: Unknown declaration. Extected '=' or '()'
                            Line: \(line)  Place: \(place)
                        """
            case let .noSuchIdentifier(str, line, place):
                return """
                        Error: No such identifier: \(str).
                            Line: \(line)  Place: \(place)
                       """
            case .unexpectedError:
                return "Error: Unexpected error."
            case .unknownOperation:
                return "Error: Unknown operation."
            }
        }
    }
    
    
    let tokensStruct: [TokenStruct]
    
    
    init(tokensStruct: [TokenStruct]) {
        self.tokensStruct = tokensStruct
    }
    
    
    // current location of the parsing phase
    var index = 0
    
    
    var canPop: Bool {
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
        
        guard canPop, case .curlyOpen = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Parser.Error.expected("{", line, place)
        }
        
        var depth = 1
        let startIndex = index
        
        while canPop {
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
        
        guard canPop, case .curlyClose = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expected("}", line, place)
        }
        let tokens = Array(self.tokensStruct[startIndex..<endIndex])
        return try Parser(tokensStruct: tokens).parse()
    }
    
    
    // MARK: - Declaration Parser
    func declarationParser() throws -> ASTnode {
    
        var returnType : Token
        
        let returnTypePopToken = getNextToken()
        
        // Return Type
        if case .int = returnTypePopToken {
            returnType = Token.int
        } else if case .float = returnTypePopToken {
            returnType = Token.float
        } else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expected("function return type", line, place)
        }
        
        // Identifier
        guard case let .identifier(identifier) = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expectedIdentifier(line, place)
        }
        
        // Function or Variable
        if case .parensOpen = peek().token {
            return try functionParser(returnType: returnType, identifier: identifier)
        } else if case .equal = peek().token {
            return try variableDeclarationParser(returnType: returnType, identifier: identifier)
        } else {
            let (line, place) = tokensStruct[index].position
            throw Error.incorrectDeclaration(line, place)
        }
        
    }
    
    
    // MARK: - Function
    func functionParser(returnType: Token, identifier: String) throws -> ASTnode {
//        var returnType : Token
//
//        let returnTypePopToken = getNextToken()
//
//        // Return Type
//        if case .int = returnTypePopToken {
//            returnType = Token.int
//        } else if case .float = returnTypePopToken {
//            returnType = Token.float
//        } else {
//            let (line, place) = tokensStruct[index - 1].position
//            throw Error.expected("function return type", line, place)
//        }
//
//        // Identifier
//        guard case let .identifier(identifier) = getNextToken() else {
//            let (line, place) = tokensStruct[index - 1].position
//            throw Error.expectedIdentifier(line, place)
//        }
//
        guard case .parensOpen = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expected("(", line, place)
        }
        guard case .parensClose = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expected(")", line, place)
        }
        
        let codeBlock = try codeBlockParser()
                
        return Function(returnType: returnType, identifier: identifier,
                                  block: codeBlock)
    }
    
    
    // MARK: - Variable Declaration
    func variableDeclarationParser(returnType: Token, identifier: String) throws -> ASTnode {
        
        guard case .equal = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expected("=", line, place)
        }
        
        let expression = try parseExpression()
        
        return VariableDeclaration(name: identifier, value: expression)
    }
    
    
    // MARK: - Variable Overriding
    func variableOverridingParser() throws -> ASTnode {
        
        // Identifier
        guard case let .identifier(identifier) = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expectedIdentifier(line, place)
        }
        
        // Checking if identifier was declared
        if identifiers[identifier] == nil {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.noSuchIdentifier(identifier, line, place)
        }
        
        guard case .equal = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expected("=", line, place)
        }
        
        let expression = try parseExpression()
        
        return VariableOverriding(name: identifier, value: expression)
    }
    
    
    // MARK: - Returning
    func returningParser() throws -> ASTnode {
        var node: ASTnode
        
        guard case .return = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expected("\'return\' in function bloc", line, place)
        }
                
        node = try parseExpression()
        
        guard canPop, case .semicolon = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expected(";", line, place)
        }
        return ReturnStatement(node: node)
    }
    
    
    // MARK:- parens ()
    func parensParser() throws -> ASTnode {
        guard case .parensOpen = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expected("(", line, place)
        }
        
        let expressionNode = try parseExpression() // ADDED - was "try parse()"
        
        guard case .parensClose = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expected(")", line, place)
        }
        
        return expressionNode
    }
    
    
    // MARK: - Expression
    func parseExpression() throws -> ASTnode {
        guard canPop else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expectedExpression(line, place)
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
                throw Error.expectedNumber(line, place)
            }
            return try prefixOperationParser()
        default:
            let (line, place) = tokensStruct[index].position
            throw Error.expectedNumber(line, place)
        }

    }
    
    func peekPrecedence() throws -> Int {
        if canPop {
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
        
        
    func getTokenPositionInCode() -> (line: Int, place: Int) {
        return tokensStruct[index - 1].position
    }
        
        
    func infixOperationParser(node: ASTnode, nodePrecedence: Int = 0) throws -> ASTnode {
        var leftNode = node
        var precedence = try peekPrecedence()
        
        while precedence >= nodePrecedence {
            guard case let .binaryOperation(op) = getNextToken() else {
                let position = getTokenPositionInCode()
                throw Error.expected("/", position.line, position.place)
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
        
    
    
    func prefixOperationParser() throws -> ASTnode {

        guard case let .unaryOperation(op) = getNextToken() else {
            let position = getTokenPositionInCode()
            throw Error.expected("-", position.line, position.place)
        }
        
        let rightNode = try valueParser()

        return PrefixOperation(operation: op, item: rightNode)
    }

    
    // MARK: - Float
    func floatNumberParser() throws -> ASTnode {
        guard case .numberFloat(_) = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expectedNumber(line, place)
        }
//        return float
        return Number(number: tokensStruct[index - 1])
    }
    
    
    // MARK: - Int
    func intNumberParser() throws -> ASTnode {
        guard case .numberInt(_, _) = getNextToken() else {
            let (line, place) = tokensStruct[index - 1].position
            throw Error.expectedNumber(line, place)
        }
//        return int
        return Number(number: tokensStruct[index - 1])
    }
    
    
    // MARK: - Parse
    func parse() throws -> ASTnode {
        var nodes: [ASTnode] = []
        while canPop {
            let token = peek()
            switch token.token {
            case .return:
                let returning = try returningParser()
                nodes.append(returning)
            case .int:
                let definition = try declarationParser()
                nodes.append(definition)
            case .float:
                let definition = try declarationParser()
                nodes.append(definition)
            case .identifier:
                let overriding = try variableOverridingParser()
                nodes.append(overriding)
            default:
                throw Error.expected("return", token.position.line, token.position.place)
            }
        }
        return CodeBlock(astNodes: nodes)
    }
    
}
