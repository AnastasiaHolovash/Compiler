//
//  Structs.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

var identifiers: [String : Int] = [:]
var adres: Int = 4

func nextAdres() {
    adres += 4
}

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


// MARK: - Variable Declaration struct
struct VariableDeclaration: ASTnode {
    let name: String
    let value: ASTnode?
    
    /// Interpreter func
    func generatingAsmCode() throws -> String {
        
        var code = ""
        
        let val = try value?.generatingAsmCode()
        
        if value is Number || value is String {
            code += """
                    mov eax, \(val ?? "?")\n
                    """
//                    mov[ebp + \(identifiers[name] ?? 0)], eax
//                    xor eax, eax\n
//                    """
        } else if value == nil {
            // Initialization of an empty variable.
            code += """
                    mov eax, 0\n
                    """
//                    mov[ebp + \(identifiers[name] ?? 0)], eax
//                    xor eax, eax\n
//                    """
        } else {
            code += val ?? ""
            code = code.deletingSufix("push eax\n")
        }
        
        // Writing variable value to dedicated space in the stack.
        code += """
                mov[ebp + \(identifiers[name] ?? 0)], eax
                xor eax, eax\n
                """
        
        return code
    }
}

// MARK: - Variable Overriding struct
struct VariableOverriding: ASTnode {
    let name: String
    let value: ASTnode
    
    /// Interpreter func
    func generatingAsmCode() throws -> String {
        let val = try value.generatingAsmCode()
        return val
    }
}

// MARK: - Return Statement struct
struct ReturnStatement: ASTnode {
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
        if leftNode is Number || leftNode is String {
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
        if rightNode is Number || rightNode is String {
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
        
        if .divide == operation {
            // Dividing: eax / ebx
            code += "cdq\nidiv ebx\n"
            
        } else if .multiply == operation {
            // Multipling: eax / ebx
            code += "cdq\nimul eax ebx\n"
            
        } else if .isLessThan == operation {
            // Compare: eax & ebx
            code += "cmp eax, ebx\nmov eax, 0\nset al\n"
            
        } else {
            throw Parser.Error.unexpectedError
        }
        
        // If operation is negative
        code += isNegative ? "neg eax\n" : ""

        // Writing result to the stack
        code += "push eax\n"
        
        return code
    }
    
}


// MARK: - Prefix Operation struct
struct PrefixOperation: ASTnode {
    
    /// Identifier of side (Left side if true, Right side if false)
    var sideLeft = true
    let operation: UnaryOperator
    let item: ASTnode
    
    /// Interpreter func
    func generatingAsmCode() throws -> String {
        
        var code  = ""
        
        let asmCode = try item.generatingAsmCode()
        
        if item is Number || item is String {
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


// MARK: - Number struct
struct Number: ASTnode {
    
    let number: TokenStruct
    
    func generatingAsmCode() throws -> String {
        var code = ""
        
        if case let .numberInt(num, type) = number.token {
             switch type {
             case .decimal:
                 code = try num.generatingAsmCode()
             case .hex:
                code = try num.decToHex()
             }
         } else if case let .numberFloat(num) = number.token {
            code = try num.generatingAsmCode()
            print("Type reduction position: Line: \(number.position.line)    Position: \(number.position.place)\n")
         }
        
        return code
    }
    
}

