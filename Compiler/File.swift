//
//  File.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

var identifiers: [String: FunctionDefinition] = [:]

protocol Node {
    func generatingAsmCode() throws -> String
}



struct Block: Node {
    let nodes: [Node]
    
    func generatingAsmCode() throws -> String {
        var codeASM = ""
        
        for item in nodes[0..<(nodes.endIndex - 1)] {
            codeASM += try item.generatingAsmCode()
        }
        
        guard let last = nodes.last else {
            throw Parser.Error.unexpectedError
        }
        
        codeASM += try last.generatingAsmCode()
        return codeASM
    }
}


