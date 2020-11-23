//
//  PrefixOperation.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation


// MARK: - Prefix Operation struct

struct PrefixOperation: ASTnode {
    
    /// Identifier of side (Left side if true, Right side if false)
    var sideLeft = true
//    let operation: UnaryOperator
    let operation: BinaryOperator
    let item: ASTnode
    
    /// Interpreter func
    func generatingAsmCode() throws -> String {
        
        var code  = ""
        
        let asmCode = try item.generatingAsmCode()

        
        if item is Number || item is VariableIdentifier {
            code += sideLeft ? "mov eax, \(asmCode)\n" : "mov ebx, \(asmCode)\n"
            code += sideLeft ? "neg eax\n" : "neg ebx\n"
        } else if var dividing = item as? InfixOperation {
            dividing.isNegative = true
            code += try dividing.generatingAsmCode()
        } else {
            code += asmCode
            code += sideLeft ? "neg eax\n" : "neg ebx\n"
        }
        
        if .minus == operation {
            return code
        } else {
            throw Parser.Error.unexpectedError
        }
    }
}
