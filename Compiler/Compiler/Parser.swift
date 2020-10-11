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
            throw Parser.Error.expected("{", position: getTokenPositionInCode())
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
            throw Error.expected("}", position: getTokenPositionInCode())
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
            throw Error.expected("function return type", position: getTokenPositionInCode())
        }
        
        // Identifier
        guard case let .identifier(identifier) = getNextToken() else {
            throw Error.expectedIdentifier(position: getTokenPositionInCode())
        }
        
        // Function or Variable
        if case .parensOpen = peek().token {
            return try functionParser(returnType: returnType, identifier: identifier)
        } else if case .equal = peek().token {
            return try variableDeclarationParser(returnType: returnType, identifier: identifier)
        } else {
            let (line, place) = tokensStruct[index].position
            throw Error.incorrectDeclaration(position: (line: line, place: place))
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
//
//            throw Error.expected("function return type", line, place)
//        }
//
//        // Identifier
//        guard case let .identifier(identifier) = getNextToken() else {
//
//            throw Error.expectedIdentifier(line, place)
//        }
//
        guard case .parensOpen = getNextToken() else {
            throw Error.expected("(", position: getTokenPositionInCode())
        }
        guard case .parensClose = getNextToken() else {
            throw Error.expected(")", position: getTokenPositionInCode())
        }
        
        let codeBlock = try codeBlockParser()
                
        return Function(returnType: returnType, identifier: identifier,
                                  block: codeBlock)
    }
    
    
    // MARK: - Variable Declaration
    func variableDeclarationParser(returnType: Token, identifier: String) throws -> ASTnode {
        
        guard case .equal = getNextToken() else {
            throw Error.expected("=", position: getTokenPositionInCode())
        }
        
        let expression = try parseExpression()
        
        guard canPop, case .semicolon = getNextToken() else {
            throw Error.expected(";", position: getTokenPositionInCode())
        }
        
        identifiers[identifier] = adres
        nextAdres()
        
        return Variable(name: identifier, value: expression)
    }
    
    
    // MARK: - Variable Overriding
    func variableOverridingParser() throws -> ASTnode {
        
        // Identifier
        guard case let .identifier(identifier) = getNextToken() else {
            throw Error.expectedIdentifier(position: getTokenPositionInCode())
        }
        
        // Checking if identifier was declared
        if identifiers[identifier] == nil {
            throw Error.noSuchIdentifier(identifier, position: getTokenPositionInCode())
        }
        
        guard case .equal = getNextToken() else {
            throw Error.expected("=", position: getTokenPositionInCode())
        }
        
        let expression = try parseExpression()
        
        guard canPop, case .semicolon = getNextToken() else {
            throw Error.expected(";", position: getTokenPositionInCode())
        }
        
        return Variable(name: identifier, value: expression)
    }
    
    
    // MARK: - Returning
    func returningParser() throws -> ASTnode {
        var node: ASTnode
        
        guard case .return = getNextToken() else {
            throw Error.expected("\'return\' in function bloc", position: getTokenPositionInCode())
        }
                
        node = try parseExpression()
        
        guard canPop, case .semicolon = getNextToken() else {
            throw Error.expected(";", position: getTokenPositionInCode())
        }
        return ReturnStatement(node: node)
    }
    
    
    // MARK:- parens ()
    func parensParser() throws -> ASTnode {
        
        guard case .parensOpen = getNextToken() else {
            throw Error.expected("(", position: getTokenPositionInCode())
        }
        
        let expressionNode = try parseExpression() // ADDED - was "try parse()"
        
        guard case .parensClose = getNextToken() else {
            throw Error.expected(")", position: getTokenPositionInCode())
        }
        
        return expressionNode
    }
    
    
    // MARK: - Expression
    func parseExpression() throws -> ASTnode {
        guard canPop else {
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
        case let .identifier(str):
            // Checking if identifier was declared
            if identifiers[str] == nil {
                
                throw Error.noSuchIdentifier(str, position: getTokenPositionInCode())
            }
            return try identifierParser()
        default:
            let (line, place) = tokensStruct[index].position
            throw Error.expectedNumber(position:(line: line, place: place))
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
        
        
//    func getTokenPositionInCode() -> (line: Int, place: Int) {
//        return tokensStruct[index - 1].position
//    }
       
    
    // MARK: - Infix Operation
    func infixOperationParser(node: ASTnode, nodePrecedence: Int = 0) throws -> ASTnode {
        var leftNode = node
        var precedence = try peekPrecedence()
        
        while precedence >= nodePrecedence {
            guard case let .binaryOperation(op) = getNextToken() else {
                throw Error.expected("/", position: getTokenPositionInCode())
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
    func identifierParser() throws -> ASTnode {
        guard case let .identifier(name) = getNextToken() else {
            
            throw Error.expectedIdentifier(position: getTokenPositionInCode())
        }
        return name
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
            case .int, .float:
                let definition = try declarationParser()
                nodes.append(definition)
            case .identifier:
                let overriding = try variableOverridingParser()
                nodes.append(overriding)
            default:
                throw Error.expected("return", position: (token.position.line, token.position.place))
            }
        }
        return CodeBlock(astNodes: nodes)
    }
    
}
