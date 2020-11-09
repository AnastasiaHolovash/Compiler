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
struct FunctionIdentifier: ASTnode, Equatable {
    
    let type: Type
    let name: String
    let arguments: [Argument]
    
    func generatingAsmCode() throws -> String {
        return ""
    }
    
    func getDeclarString() -> String {
        var str = "\(type) \(name)("
        for item in arguments {
            str += "\(item.type) \(item.name), "
        }
        str = str.deletingSufix(",") + ");"
        return str
    }
}

/// Func argument for Function declaration and definition
struct Argument: ASTnode, Equatable {
    let name: String
    let type: Type
    
    /// Is compared only type because argument can has different names in C
    static func == (lhs: Argument, rhs: Argument) -> Bool {
        return lhs.type == rhs.type ? true : false
    }
    
    func generatingAsmCode() throws -> String {
        return ""
    }
}


struct FunctionCall: ASTnode {
    
    let name: String
    let arguments: [ASTnode]
    
    func generatingAsmCode() throws -> String {
        var code = ""
        for arg in arguments {
            let number = try arg.generatingAsmCode()
            code += "push \(number)\n"
        }
        return code + "call _\(name)\n"
    }
}
