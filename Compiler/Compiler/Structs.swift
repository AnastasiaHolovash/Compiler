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
        identifiers[identifier] = self
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
//        var buffer = ""
//
//        if case let .numberInt(num, type) = number.token {
//            switch type {
//            case .decimal:
//                buffer += try num.generatingAsmCode()
//            case .hex:
//                buffer += try num.decToHex()
//            }
//        } else if case let .numberFloat(num) = number.token {
//            buffer += try num.generatingAsmCode()
//            print("Type reduction position: Line: \(number.position.line)    Position: \(number.position.place)\n")
//        }
//
//        return
//            """
//            mov eax, \(buffer)
//            mov b, eax
//            """
        return ""
    }
}


struct InfixOperation: ASTnode {
    
    let operation: BinaryOperator
    let leftNode: ASTnode
    let rightNode: ASTnode
    
    func generatingAsmCode() throws -> String {
        
        let left = try leftNode.generatingAsmCode()
        let right = try rightNode.generatingAsmCode()
        
//        guard case let .binaryOperation(item) = operation else {
//            throw Parser.Error.unexpectedError
//        }
        
        if .divideBy == operation {
            return left + "/" + right
        } else {
            throw Parser.Error.unexpectedError
        }
    }
}


struct PrefixOperation: ASTnode {
    
    let operation: UnaryOperator
    let item: ASTnode
    
    func generatingAsmCode() throws -> String {
        
        let some = try item.generatingAsmCode()
        
//        guard case let .unaryOperation(item) = operation.token else {
//            throw Parser.Error.unexpectedError
//        }
        
        if .minus == operation {
            return "-" + some
        } else {
            throw Parser.Error.unexpectedError
        }
    }
}


var identifiers: [String: Function] = [:]
