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
        return position > 0 ? "[ebp + \(position)]" : "[ebp - \(position * -1)]"
    }
}
