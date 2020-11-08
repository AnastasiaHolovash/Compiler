//
//  InfixOperation.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation


// MARK: - Infix Operation struct

struct InfixOperation: ASTnode {
    
    let operation: BinaryOperator
    let leftNode: ASTnode
    let rightNode: ASTnode
    
    var isNegative = false
    
    func rightAndLeftGeneratingCode() throws -> String {
        
        var code = ""
        /// Write "pop eax\n" if needed and add to code in the end
        var popLeft = ""
        /// Write "pop ebx\n" if needed and add to code in the end
        var popRight = ""
        /// Editiion code bufer
        var codeBufer = ""
        
        let left = try leftNode.generatingAsmCode()
        let right = try rightNode.generatingAsmCode()
        
        // Left node code generation
        if leftNode is Number || leftNode is VariableIdentifier {
            if right.hasSuffix("push eax\n") {
                codeBufer += "mov eax, \(left)\n"
            } else {
                code += "mov eax, \(left)\n"
            }
        } else if left.hasSuffix("push eax\n") {
            code += left
            popLeft += "pop eax\n"
        } else if leftNode is PrefixOperation {
            if right.hasSuffix("push eax\n") {
                codeBufer += left
            } else {
                code += left
            }
        } else {
            code += left
        }
        
        // Right node code generation
        if rightNode is Number || rightNode is VariableIdentifier {
            code += "mov ebx, \(right)\n"
        } else if right.hasSuffix("push eax\n") {
            code += right
            popRight += "pop ebx\n"
        } else if var prefixR = rightNode as? PrefixOperation {
            prefixR.sideLeft = false
            code += try prefixR.generatingAsmCode()
        } else {
            code += right
        }
        
        code += codeBufer
        code += popRight
        code += popLeft
        return code
    }
    
    
    /// Interpreter func
    func generatingAsmCode() throws -> String {
        
        var code = try rightAndLeftGeneratingCode()
        
        switch operation {
        case .divide:
            // Dividing: eax / ebx
            code += "cdq\nidiv ebx\n"
        case .multiply:
            // Multipling: eax / ebx
            code += "cdq\nimul eax, ebx\n"
        case .isLessThan:
            // Compare: eax & ebx
            code += "cmp eax, ebx\nsetl al\nmovzx eax, al\n"
        case .divideEqual:
            // Dividing: eax / ebx
            code += "cdq\nidiv ebx\n"
        }
        
        // If operation is negative
        code += isNegative ? "neg eax\n" : ""

        // Writing result to the stack
        code += "push eax\n"
        
        return code
    }
    
}
