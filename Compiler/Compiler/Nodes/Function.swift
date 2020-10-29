//
//  Function.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation


// MARK: - Function struct

struct Function: ASTnode {
    let returnType: Token
    let identifier: String
    let block: ASTnode

    /// Interpreter func
    func generatingAsmCode() throws -> String {

        var code =  """
                    push ebp
                    mov ebp, esp\n
                    """
        code += getNextAdres() > 4 ? "sub esp, \(getNextAdres())\n\n" : "\n"
        
        code += try block.generatingAsmCode()
        
        code += """
                _return:
                \nmov esp, ebp
                pop ebp
                mov b, eax\n
                """
        
        return code
    }
}