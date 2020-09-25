//
//  File.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

var identifiers: [String: Function] = [:]

protocol ASTnode {
    func generatingAsmCode() throws -> String
}

