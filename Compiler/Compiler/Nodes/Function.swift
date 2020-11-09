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
    let arguments: [Argument]
    let identifier: String
    let block: ASTnode

    /// Interpreter func
    func generatingAsmCode() throws -> String {

        var code =  """
                    \n_\(identifier):
                    ; Stack frame for \(identifier)
                    push ebp
                    mov ebp, esp\n
                    """
        code += Parser.getNextAdres() > 4 ? "sub esp, \(Parser.adres)\n\n" : "\n"
        
        code += try block.generatingAsmCode()
        
        code += """
                \n_\(identifier)_return:
                """
        
        code += """
                \n\n; Restore old EBP for \(identifier)
                mov esp, ebp
                pop ebp
                ret
                """
        
        return code
    }
}


// MARK: - Function identifier

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
        str = str.deletingSufix(", ") + ");"
        return str
    }
}


// MARK: - Argument

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


// MARK: - Function call

struct FunctionCall: ASTnode {
    
    let name: String
    let arguments: [ASTnode]
    
    func generatingAsmCode() throws -> String {
        var code = ""
        for arg in arguments {
            let number = try arg.generatingAsmCode()
            code += "push \(number)\n"
        }
        code += "call _\(name)\n"
        return code + "add esp, \(arguments.count)\n"
    }
}
