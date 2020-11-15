//
//  WhileStatement.swift
//  Compiler
//
//  Created by Anastasia Holovash on 15.11.2020.
//

import Foundation

// MARK: -  While struct

struct  WhileStatement: ASTnode {
    
    let condition: ASTnode
    let block: ASTnode
    
    
    func generatingAsmCode() throws -> String {
        var result = ""
        let newFlag = Parser.getNextFlag()
        if condition is Number || condition is VariableIdentifier {
            let number = try condition.generatingAsmCode()
            result += "mov eax, \(number)\n"
        } else {
            result += try condition.generatingAsmCode()
        }
        
        result = result.deletingSufix("push eax\n")
        
        result += "cmp eax, 0\n"
        
        result += "je _post_conditional_\(newFlag)\n"
        
        result += try block.generatingAsmCode()
        
        result += "_post_conditional_\(newFlag):\n"
        
        return result
    }
}
