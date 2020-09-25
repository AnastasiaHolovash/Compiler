//
//  Parser.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

// MARK: - PARSER
class Parser {
    
    /// Detection and derivation of Errors
    enum Error: Swift.Error, LocalizedError {
        
        case expectedNumber(Int, Int)
        case expectedIdentifier(Int, Int)
        case expectedExpression(Int, Int)
        case expectedNumberType(String ,Int, Int)
        case expected(String, Int, Int)
        case unexpectedError
        
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
            case .unexpectedError:
                return "Error: Unexpected error."
            }
        }
    }
    
    let tokensStruct: [TokenStruct]
    
    // current location of the parsing phase
    var index = 0
    
    init(tokensStruct: [TokenStruct]) {
        self.tokensStruct = tokensStruct
    }
    
    var canPop: Bool {
        return index < tokensStruct.count
    }
    
    // A way of checking the element at the current location
    // without incrementing the index
    func peek() -> Token {
        return tokensStruct[index].token
    }
    
    // A way of checking the element at the current location,
    // but ultimately incrementing the index.
    func popToken() -> Token {
        let token = tokensStruct[index].token
        index += 1
        return token
    }
    
    func parseIdentifier() throws -> Node {
        guard case let .identifier(name) = popToken() else {
            let (line, place) = tokensStruct[index].position
            throw Error.expectedIdentifier(line, place)
        }
        return name
    }
    
    func parseFloatNumber() throws -> Node {
        guard case let .numberFloat(float) = popToken() else {
            let (line, place) = tokensStruct[index].position
            throw Error.expectedNumber(line, place)
        }
        return float
    }
    
    func parseIntNumber() throws -> Node {
        guard case let .numberInt(int, _) = popToken() else {
            let (line, place) = tokensStruct[index].position
            throw Error.expectedNumber(line, place)
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
        default:
            let (line, place) = tokensStruct[index].position
            throw Error.expectedExpression(line, place)
        }
    }

    func parseReturning() throws -> Node {
//        var number : Token
        var numberPosition: TokenStruct
        
        guard case .return = popToken() else {
            let (line, place) = tokensStruct[index].position
            throw Error.expected("\'return\' in function bloc", line, place)
        }
        
        if case let .numberInt(num, type) = peek() {
//            number = Token.numberInt(num, type)
            numberPosition = tokensStruct[index]
            index += 1
        } else if case let .numberFloat(num) = peek() {
//            number = Token.numberFloat(num)
            numberPosition = tokensStruct[index]
            index += 1
        } else {
            let (line, place) = tokensStruct[index].position
            throw Error.expectedNumber(line, place)
        }
        
        guard case .semicolon = popToken() else {
            let (line, place) = tokensStruct[index].position
            throw Error.expected(";", line, place)
        }
        return ReturnStatement(number: numberPosition)
    }
    
    func parseFunctionDefinition() throws -> Node {
        var returnType : Token
        
        let returnTypePopToken = popToken()
        if case .int = returnTypePopToken {
            returnType = Token.int
        } else if case .float = returnTypePopToken {
            returnType = Token.float
        } else {
            let (line, place) = tokensStruct[index].position
            throw Error.expected("function return type", line, place)
        }
        guard case let .identifier(identifier) = popToken() else {
            let (line, place) = tokensStruct[index].position
            throw Error.expectedIdentifier(line, place)
        }
        guard case .parensOpen = popToken() else {
            let (line, place) = tokensStruct[index].position
            throw Error.expected("(", line, place)
        }
        guard case .parensClose = popToken() else {
            let (line, place) = tokensStruct[index].position
            throw Error.expected(")", line, place)
        }
        
        let possibleErrorIndex = index
        let codeBlock = try parseCurlyCodeBlock()
        
        
        guard let codeBlockBlock = codeBlock as? Block else {
            let (line, place) = tokensStruct[possibleErrorIndex].position
            throw Error.expected("Function return block", line, place)
        }
        guard let returnStatement = codeBlockBlock.nodes[0] as? ReturnStatement else {
            let (line, place) = tokensStruct[possibleErrorIndex + 1].position
            throw Error.expected("Function return block", line, place)
        }
        
        if case Token.numberInt(_ , _) = returnStatement.number.token {
            if case .float = returnType {
                let (line, place) = tokensStruct[possibleErrorIndex + 2].position
                throw Error.expectedNumberType("float", line, place)
            }
        } else if case .numberFloat(_) = returnStatement.number.token {
            if case .int = returnType {
                let (line, place) = tokensStruct[possibleErrorIndex + 2].position
                throw Error.expectedNumberType("int", line, place)
            }
        }
                
        return FunctionDefinition(returnType: returnType, identifier: identifier,
                                  block: codeBlock)
    }
    
    func parseCurlyCodeBlock() throws -> Node {
        guard canPop, case .curlyOpen = popToken() else {
            let (line, place) = tokensStruct[index].position
            throw Parser.Error.expected("{", line, place)
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
            let (line, place) = tokensStruct[index].position
            throw Error.expected("}", line, place)
        }
        
        let tokens = Array(self.tokensStruct[startIndex..<endIndex])
        return try Parser(tokensStruct: tokens).parse()
    }

}
