//
//  ReturnStatement.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation


// MARK: - Return Statement struct

struct ReturnStatement: ASTnode {
    let node : ASTnode
    let funcIdentifier: String
    /// Interpreter func
    func generatingAsmCode() throws -> String {
        
        var code = ""
        
        if node is Number || node is VariableIdentifier {
            code = "mov eax, \(try node.generatingAsmCode())\n"
        } else {
            code = try node.generatingAsmCode()
        }
        code = code.deletingSufix("push eax\n")
        code += "jmp _\(funcIdentifier)_return\n"
        return code
    }
}
