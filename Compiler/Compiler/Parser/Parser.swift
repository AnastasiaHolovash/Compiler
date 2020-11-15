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

class Parser {

    // MARK:- Init
    
    /// List of tokens with.
    let tokensStruct: [TokenStruct]
    
    /// Value of block depth
    var blockDepth: Int
    
    /// True if block can be breaked or continued
    var canBreak: Bool
    
    init(tokensStruct: [TokenStruct], blockDepth: Int = 0, canBreak: Bool = false) {
        self.tokensStruct = tokensStruct
        self.blockDepth = blockDepth
        self.canBreak = canBreak
    }

    
    // MARK:- Statics
    
    /// For tracking functions flags names for asm code.
    static var funcFlagsName = 0
    /// For tracking while statements flags names for asm code.
    static var whileFlagsUniqueName = 0
    static var whileFlagsCurentName = 0
    /// For tracking variables adreses for asm code.
    static var adres: Int = 0
    
    static var variablesIdentifiers: [Int : [String : Int]] = [:]
    static var functionDeclaredIdentifiers: [Int : [FunctionIdentifier]] = [:]
    static var functionDefinedIdentifiers: [FunctionIdentifier] = []
    static var functionCalledIdentifiers: [(identifier: FunctionIdentifier, position: (line: Int, place: Int))] = []
    static var currentFuncScope: String?
    
    /**
     Increments and returns funcFlagsName.
     */
    static func getNextFuncFlag() -> Int {
        Parser.funcFlagsName += 1
        return Parser.funcFlagsName
    }
    
    /**
     Increments and returns whileFlagsName.
     */
    static func getNextWhileFlag() -> Int {
        Parser.whileFlagsUniqueName += 1
        Parser.whileFlagsCurentName = Parser.whileFlagsUniqueName
        return Parser.whileFlagsUniqueName
    }
    
    /**
     Calculates and returns next adres.
     */
    static func getNextAdres() -> Int {
        Parser.adres -= 4
        return Parser.adres
    }
    
    
    // MARK: - Instanc`s
    
    /// Current location of the parsing phase.
    var index = 0
    
    /// True if there is next token.
    var canGet: Bool {
        return index < tokensStruct.count ? true : false
    }
    
    /// True if there is through one token.
    var canGetThroughOne: Bool {
        return index + 1 < tokensStruct.count ? true : false
    }
    
    /**
     A way of checking the element at the current location without incrementing the index.
     
    To check WITH incrementing the index use getNextToken().
     */
    func peek() -> TokenStruct {
        return tokensStruct[index]
    }
    
    func peekThroughOne() -> TokenStruct {
        return tokensStruct[index + 1]
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
        Parser.functionDeclaredIdentifiers[blockDepth] = []

        while canGet {
            let token = peek()
            switch token.token {
            case .return:
                let returning = try returningParser()
                nodes.append(returning)
                
            case .type:
                let definition = try declarationParser()
                if definition is Function {
                    Parser.adres = 0
                }
                nodes.append(definition)
                
            case .identifier:
                var identifier: ASTnode
                if case .parensOpen = peekThroughOne().token {
                    identifier = try functionCallParser()
                    try check(token: .semicolon)
                } else {
                    identifier = try variableOverridingParser()
                }
                nodes.append(identifier)
                
            case .if:
                let ifStatement = try ifStatementParser()
                nodes.append(ifStatement)
                
            case .curlyOpen:
//                let block = canBreak ? try codeBlockParser(canBreak: true) : try codeBlockParser()
                let block = try codeBlockParser()
                
                // Clear deeper block`s functions and variables declaretions
                Parser.variablesIdentifiers[blockDepth + 1] = nil
                Parser.functionDeclaredIdentifiers[blockDepth + 1] = nil
                
                nodes.append(block)
                
            case .while:
                let whileStatement = try whileStatementParser()
                nodes.append(whileStatement)
                
            case .break:
                let breakStatement = try breakParser()
                nodes.append(breakStatement)
                
            case .continue:
                let continueStatement = try continueParser()
                nodes.append(continueStatement)
                
            default:
                throw Error.unexpectedExpresion(position: token.position)
            }
        }

        if blockDepth == 0 {
            try Parser.chackIfAllCalledFuncsWasDefine()
        }
        
        return CodeBlock(astNodes: nodes)
    }
    
    
    static func chackIfAllCalledFuncsWasDefine() throws {
        
        for item in Parser.functionCalledIdentifiers {
            if !Parser.functionDefinedIdentifiers.contains(item.identifier) {
                throw Error.functionWasntDefine(item.identifier.name, position: item.position)
            }
        }
        
        if !Parser.functionDefinedIdentifiers.contains(FunctionIdentifier(type: .float, name: "main", arguments: [])) && !Parser.functionDefinedIdentifiers.contains(FunctionIdentifier(type: .int, name: "main", arguments: [])) {
            throw Error.funcMainMustBeDefine
        }
    }
    
}
