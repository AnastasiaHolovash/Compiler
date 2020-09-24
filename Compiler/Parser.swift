//
//  Parser.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

// MARK: - PARSER
class Parser {
    
    enum Error: Swift.Error {
        case expectedNumber
        case expectedIdentifier
        case expectedOperator
        case expectedExpression
        case expected(String)
        case notDefined(String)
        case invalidParameters(toFunction: String)
        case alreadyDefined(String)
    }
    
    let tokens: [Token]
    
    // current location of the parsing phase
    var index = 0
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    var canPop: Bool {
        return index < tokens.count
    }
    
    // A way of checking the element at the current location
    // without incrementing the index
    func peek() -> Token {
        return tokens[index]
    }
    
    // A way of checking the element at the current location,
    // but ultimately incrementing the index.
    func popToken() -> Token {
        let token = tokens[index]
        index += 1
        return token
    }
    
    func parseIdentifier() throws -> Node {
        guard case let .identifier(name) = popToken() else {
            throw Error.expectedIdentifier
        }
        return name
    }
    
    func parseFloatNumber() throws -> Node {
        guard case let .numberFloat(float) = popToken() else {
            throw Error.expectedNumber
        }
        return float
    }
    
    func parseIntNumber() throws -> Node {
        guard case let .numberInt(int, _) = popToken() else {
            throw Error.expectedNumber
        }
        return int
    }
    
    func parse() throws -> Node {
        var nodes: [Node] = []
        while canPop {
            let token = peek()
            switch token {
            case .return:
                let returning = try parseReturning()
                nodes.append(returning)
            case .int:
                let definition = try parseFunctionDefinition()
                nodes.append(definition)
            case .float:
                let definition = try parseFunctionDefinition()
                nodes.append(definition)
            default:
                break
//                let expression = try parseExpression()
//                nodes.append(expression)
            }
        }
        return Block(nodes: nodes)
    }
    
    // getting either a number or a parenthesized expression.
    func parseValue() throws -> Node {
        switch (peek()) {
        case .numberInt:
            return try parseIntNumber()
        case .numberFloat:
            return try parseFloatNumber()
//        case .parensOpen:
//            return try parseParens()
        case .identifier:
            guard let identifier = try parseIdentifier() as? String else {
                throw Error.expectedIdentifier
            }
            guard canPop, case .parensOpen = peek() else {
                return identifier
            }
            return FunctionCall(identifier: identifier)
        default:
            throw Error.expectedExpression
        }
    }

    func parseReturning() throws -> Node {
        var number : Token
        
        guard case .return = popToken() else {
            throw Error.expected("\"return\" in function bloc")
        }
        
        if case let .numberInt(num, type) = popToken(){
            number = Token.numberInt(num, type)
        } else if case let .numberFloat(num) = popToken(){
            number = Token.numberFloat(num)
        } else {
            throw Error.expected("number")
        }
        
        guard case .semicolon = popToken() else {
            throw Error.expected(";")
        }
        return ReturnStatement(number: number)
    }
    
    func parseFunctionDefinition() throws -> Node {
        var returnType : Token
        
        let returnTypePopToken = popToken()
        if case .int = returnTypePopToken {
            returnType = Token.int
        } else if case .float = returnTypePopToken {
            returnType = Token.float
        } else {
            throw Error.expected("function return type")
        }
        guard case let .identifier(identifier) = popToken() else {
            throw Error.expectedIdentifier
        }
        guard case .parensOpen = popToken() else {
            throw Error.expected("(")
        }
        guard case .parensClose = popToken() else {
            throw Error.expected(")")
        }
        let codeBlock = try parseCurlyCodeBlock()
        
        
        guard let codeBlockBlock = codeBlock as? Block else {
            throw Error.expected("function return block")
        }
        guard let returnStatement = codeBlockBlock.nodes[0] as? ReturnStatement else {
            throw Error.expected("function return block")
        }
        
        if case Token.numberInt(_ , _) = returnStatement.number {
            if case .float = returnType {
                throw Error.expected("---")
            }
        } else if case .numberFloat(_) = returnStatement.number {
            if case .int = returnType {
                throw Error.expected("---")
            }
        }
                
        return FunctionDefinition(returnType: returnType, identifier: identifier,
                                  block: codeBlock)
    }
    
    func parseCurlyCodeBlock() throws -> Node {
        guard canPop, case .curlyOpen = popToken() else {
            throw Parser.Error.expected("{")
        }
        
        var depth = 1
        let startIndex = index
        
        while canPop {
            guard case .curlyClose = peek() else {
                if case .curlyOpen = peek() {
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
        
        guard canPop, case .curlyClose = popToken() else {
            throw Error.expected("}")
        }
        
        let tokens = Array(self.tokens[startIndex..<endIndex])
        return try Parser(tokens: tokens).parse()
    }

}
