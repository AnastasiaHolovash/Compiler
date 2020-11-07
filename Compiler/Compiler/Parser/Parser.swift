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
    
    /// Value of block depth
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
    
    
    // MARK: - Parse
    func parse() throws -> ASTnode {
        var nodes: [ASTnode] = []
        while canGet {
            let token = peek()
            switch token.token {
            case .return:
                let returning = try returningParser()
                nodes.append(returning)
            case .type:
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
