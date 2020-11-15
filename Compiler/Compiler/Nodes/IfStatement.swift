//
//  IfStatement.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation


// MARK: - If else struct

struct IfStatement: ASTnode {
    
    let condition: ASTnode
    let ifBlock: ASTnode
    let elseBlock: ASTnode?
    
    
    func generatingAsmCode() throws -> String {
        var result = ""
        let newFlag = Parser.getNextFuncFlag()
        if condition is Number || condition is VariableIdentifier {
            let number = try condition.generatingAsmCode()
            result += "mov eax, \(number)\n"
        } else {
            result += try condition.generatingAsmCode()
        }
        
        result = result.deletingSufix("push eax\n")
        
        result += "cmp eax, 0\n"
        
        if elseBlock == nil {
            result += "je _post_conditional_\(newFlag)\n"
        } else {
            result += "je _else_\(newFlag)\n"
        }
        
        result += try ifBlock.generatingAsmCode()
        
        if let elseBlock = elseBlock {
            result += "jmp _post_conditional_\(newFlag)\n"
            result += "_else_\(newFlag):\n"
            result += try elseBlock.generatingAsmCode()
        }
        
        result += "_post_conditional_\(newFlag):\n"
        
        return result
    }
}
