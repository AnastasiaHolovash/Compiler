//
//  Identifier.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation


// MARK: - Identifier struct

struct VariableIdentifier: ASTnode {
    
    let name: String
    let position: Int
    
    func generatingAsmCode() throws -> String {
        return "[ebp - \(position)]"
    }
}

// MARK: - Identifier struct

/// For Function declaration
struct FunctionIdentifier: ASTnode {
    
    let type: Type
    let name: String
    let arguments: [Argument]
    
    func generatingAsmCode() throws -> String {
        return ""
    }
}

/// Func argument for Function declaration and definition
struct Argument: ASTnode {
    let name: String
    let type: Type
    
    func generatingAsmCode() throws -> String {
        return ""
    }
}


struct FunctionCall: ASTnode {
    
    let name: String
    let arguments: [Number]
    
    func generatingAsmCode() throws -> String {
        var code = ""
        for arg in arguments {
            let number = try arg.generatingAsmCode()
            code += "push \(number)\n"
        }
        return code + "call _\(name)\n"
    }
}
