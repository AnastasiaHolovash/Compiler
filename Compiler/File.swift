//
//  File.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

var identifiers: [String: FunctionDefinition] = [:]

protocol Node {
    func interpret() throws -> String
}



struct Block: Node {
    let nodes: [Node]
    
    func interpret() throws -> String {
        var codeASM = ""
        
        for item in nodes[0..<(nodes.endIndex - 1)] {
            codeASM += try item.interpret()
        }
        
        guard let last = nodes.last else {
            throw Parser.Error.unexpectedError
        }
        
        codeASM += try last.interpret()
        return codeASM
    }
}


