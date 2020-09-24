//
//  Structs.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

struct FunctionDefinition: Node {
    let returnType: Token
    let identifier: String
    let block: Node

    func interpret() throws -> String {
        identifiers[identifier] = self
        
        let codeASM = try block.interpret()
        
        switch returnType {
        case .int:
            return
                """
                \tint b;
                \t__asm {
                \(codeASM)
                \t}
                \tcout << b << endl;
                """
        case .float:
            return
                """
                \tfloat b;
                \t__asm {
                \(codeASM)
                \t}
                \tcout << b << endl;
                """
        default:
            return ""
        }
    }
    
    func returnTypeCheck(define: Token, fact: Node) -> Bool {
        
        return true
    }
}

struct ReturnStatement: Node {
    let number : Token
    
    func interpret() throws -> String {
        var buffer = ""
        
        if case let .numberInt(num, type) = number {
            switch type {
            case .decimal:
                buffer += try num.interpret()
            case .hex:
                buffer += try num.decToHex()
            }
        } else if case let .numberFloat(num) = number {
            buffer += try num.interpret()
        }
        
        return
            """
            \t\tmov eax, \(buffer)
            \t\tmov b, eax
            """
    }
}
