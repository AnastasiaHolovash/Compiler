//
//  Function.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation


// MARK: - Function struct

struct Function: ASTnode {
    let returnType: Type
    let arguments: [(String, Type)]
    let identifier: String
    let block: ASTnode

    /// Interpreter func
    func generatingAsmCode() throws -> String {

        var code =  """
                    \n_\(identifier):
                    push ebp
                    mov ebp, esp\n
                    """
        code += Parser.getNextAdres() > 4 ? "sub esp, \(Parser.adres)\n\n" : "\n"
        
        code += try block.generatingAsmCode()
        
        code += """
                _return:
                """
        
        code += """
                \n\nmov esp, ebp
                pop ebp
                mov b, eax\n
                """
        
        return code
    }
}
