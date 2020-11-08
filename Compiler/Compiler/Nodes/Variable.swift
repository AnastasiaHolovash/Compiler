//
//  Variable.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation


// MARK: - Variable struct
struct Variable: ASTnode {
    let identifier: VariableIdentifier
    let value: ASTnode?
    
    /// Interpreter func
    func generatingAsmCode() throws -> String {
        
        var code = ""
        
        let val = try value?.generatingAsmCode()
        
        if value is Number || value is VariableIdentifier {
            code += """
                    mov eax, \(val ?? "?")\n
                    """
        } else if value == nil {
            // Initialization of an empty variable.
            code += """
                    mov eax, 0\n
                    """
        } else {
            code += val ?? ""
            code = code.deletingSufix("push eax\n")
        }
        
        // Writing variable value to dedicated space in the stack.
        code += """
                mov[ebp - \(identifier.position)], eax\n
                """
        
        return code
    }
}
