//
//  Structs.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

// MARK: - Code Block struct
struct CodeBlock: ASTnode {
    let astNodes: [ASTnode]
    
    /// Interpreter func
    func generatingAsmCode() throws -> String {
        var codeASM = ""
        
        for item in astNodes[0..<(astNodes.endIndex - 1)] {
            codeASM += try item.generatingAsmCode()
        }
        
        guard let last = astNodes.last else {
            throw Parser.Error.unexpectedError
        }
        
        codeASM += try last.generatingAsmCode()
        return codeASM
    }
}


// MARK: - Function struct
struct Function: ASTnode {
    let returnType: Token
    let identifier: String
    let block: ASTnode

    /// Interpreter func
    func generatingAsmCode() throws -> String {
//        identifiers[identifier] = self
        let codeASM = try block.generatingAsmCode()
        
        return codeASM
    }
}


// MARK: - Return Statement struct
struct ReturnStatement: ASTnode {
//    let
    let node : ASTnode
    
    /// Interpreter func
    func generatingAsmCode() throws -> String {
        
        let code = try node.generatingAsmCode()
        
        return code.deletingSufix("push eax\n") + "mov b, eax\n"
    }
}


// MARK: - Infix Operation struct
struct InfixOperation: ASTnode {
    
    let operation: BinaryOperator
    let leftNode: ASTnode
    let rightNode: ASTnode
    
    var isNegative = false
    
    func generatingAsmCode() throws -> String {
        
        var code = ""
        /// Write "pop eax\n" if needed and add to code in the end
        var popLeft = ""
        /// Write "pop ebx\n" if needed and add to code in the end
        var popRight = ""
        
        let left = try leftNode.generatingAsmCode()
        let right = try rightNode.generatingAsmCode()
        
        // Left node code generation
        if leftNode is Int || leftNode is Float {
            code += "mov eax, \(left)\n"
        } else if left.hasSuffix("push eax\n") {
            code += left
//            code += "mov eax, ss : [esp]\nadd esp, 4\n"
            popLeft += "pop eax\n"
        } else if var prefixL = leftNode as? PrefixOperation {
            prefixL.sideLeft = true
            code += try prefixL.generatingAsmCode()
        } else {
            code += left
        }
        
        // Right node code generation
        if rightNode is Int || rightNode is Float {
            code += "mov ebx, \(right)\n"
        } else if right.hasSuffix("push eax\n") {
            code += right
//            code += "mov ebx, ss : [esp]\nadd esp, 4\n"
            popRight += "pop ebx\n"
        } else if var prefixR = rightNode as? PrefixOperation {
            prefixR.sideLeft = false
            code += try prefixR.generatingAsmCode()
        } else {
            code += right
        }
        
        
        if .divideBy == operation {
            code += popRight
            code += popLeft
            
            // Dividing: eax / ebx
            code += "cdq\nidiv ebx\n"
            
            // If dividing is negative
            code += isNegative ? "neg eax\n" : ""
    
            // Writing dividion result to the stack
//            code += "sub esp, 4\nmove ss : [esp], eax\n"
            code += "push eax\n"
            
            return code
        } else {
            throw Parser.Error.unexpectedError
        }
    }
}


// MARK: - Prefix Operation struct
struct PrefixOperation: ASTnode {
    
    /// Identifier of side (Left side if true, Right side if false)
    var sideLeft = true
    let operation: UnaryOperator
    let item: ASTnode
    
    func generatingAsmCode() throws -> String {
        
        var code  = ""
        
        let asmCode = try item.generatingAsmCode()
        
        if item is Int || item is Float {
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


//var identifiers: [String: Function] = [:]
