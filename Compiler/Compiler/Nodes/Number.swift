//
//  Number.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation


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
