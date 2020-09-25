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

    func generatingAsmCode() throws -> String {
        identifiers[identifier] = self
        
        let codeASM = try block.generatingAsmCode()
        
        return
            """
            \tint b;
            \t__asm {
            \(codeASM)
            \t}
            \tcout << b << endl;
            """
    }
}

struct ReturnStatement: Node {
    let number : TokenStruct
    
    func generatingAsmCode() throws -> String {
        var buffer = ""
        
        if case let .numberInt(num, type) = number.token {
            switch type {
            case .decimal:
                buffer += try num.generatingAsmCode()
            case .hex:
                buffer += try num.decToHex()
            }
        } else if case let .numberFloat(num) = number.token {
            buffer += try num.generatingAsmCode()
            print("Type reduction position: Line: \(number.position.line)    Position: \(number.position.place)\n")
        }
        
        return
            """
            \t\tmov eax, \(buffer)
            \t\tmov b, eax
            """
    }
}
