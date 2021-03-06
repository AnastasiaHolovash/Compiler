//
//  CodeBlockParesr.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation

extension Parser {
    
    // MARK: - Code block
    
    /**
     - parameter canBreak: True if block can be breaked or continued, false - if not.
     */
    func codeBlockParser(canBreak: Bool = false) throws -> ASTnode {
        
        try check(token: .curlyOpen)
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
        
        if Parser.variablesIdentifiers[blockDepth + 1] == nil {
            Parser.variablesIdentifiers[blockDepth + 1] = [:]
        }
        Parser.functionDeclaredIdentifiers[blockDepth + 1] = []
        
        return try Parser(tokensStruct: tokens, blockDepth: blockDepth + 1, canBreak: self.canBreak || canBreak).parse()
    }
    
}
