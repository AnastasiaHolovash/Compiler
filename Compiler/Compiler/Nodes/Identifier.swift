//
//  Identifier.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

import Foundation


// MARK: - Identifier struct

struct Identifier: ASTnode {
    
    let name: String
    let position: Int
    
    func generatingAsmCode() throws -> String {
        return "[ebp - \(position)]"
    }
    
}
