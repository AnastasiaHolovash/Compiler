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
        let newFlag = Parser.getNextWhileFlag()
        var result = "\n_while_\(newFlag):\n"
        
        if condition is Number || condition is VariableIdentifier {
            let number = try condition.generatingAsmCode()
            result += "mov eax, \(number)\n"
        } else {
            result += try condition.generatingAsmCode()
        }
        
        result = result.deletingSufix("push eax\n")
        
        result += "cmp eax, 0\n"
        
        result += "je _end_while_\(newFlag)\n"
        
        result += try block.generatingAsmCode()
        
        result += "jmp _while_\(newFlag)\n"
        
        result += "_end_while_\(newFlag):\n\n"
        
        Parser.whileFlagsCurentName -= 1
        
        return result
    }
}


struct Break: ASTnode {
    
    func generatingAsmCode() throws -> String {
        return "jmp _end_while_\(Parser.whileFlagsCurentName)\n"
    }
}


struct Continue: ASTnode {
    
    func generatingAsmCode() throws -> String {
        return "jmp _while_\(Parser.whileFlagsCurentName)\n"
    }
}
