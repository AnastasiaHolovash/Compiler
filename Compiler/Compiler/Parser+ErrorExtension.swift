//
//  Parser+ErrorExtension.swift
//  Compiler
//
//  Created by Головаш Анастасия on 10.10.2020.
//

import Foundation

extension Parser {
    
    /// Detection and derivation of Errors
    enum Error: Swift.Error, LocalizedError {
        
        case expectedNumber(Int, Int)
        case expectedIdentifier(Int, Int)
        case expectedExpression(Int, Int)
        case expectedNumberType(String ,Int, Int)
        case expected(String, Int, Int)
        case incorrectDeclaration(Int, Int)
        case noSuchIdentifier(String, Int, Int)
        case unexpectedError
        case unknownOperation
        
        var errorDescription: String? {
            switch self {
            case let .expectedNumber(line, place):
                return """
                        Error: Expected number.
                            Line: \(line)  Place: \(place)
                       """
            case let .expectedIdentifier(line, place):
                return """
                        Error: Expected identifier.
                            Line: \(line)  Place: \(place)
                       """
            case let .expectedExpression(line, place):
                return """
                        Error: Expression expected.
                            Line: \(line)  Place: \(place)
                        """
            case let .expectedNumberType(str, line, place):
                return """
                        Error: Extected number type \(str).
                            Line: \(line)  Place: \(place)
                       """
            case let .expected(str, line, place):
                return """
                        Error: Extected \'\(str)\'.
                            Line: \(line)  Place: \(place)
                       """
            case let .incorrectDeclaration(line, place):
                return """
                        Error: Unknown declaration. Extected '=' or '()'
                            Line: \(line)  Place: \(place)
                        """
            case let .noSuchIdentifier(str, line, place):
                return """
                        Error: No such identifier: \(str).
                            Line: \(line)  Place: \(place)
                       """
            case .unexpectedError:
                return "Error: Unexpected error."
            case .unknownOperation:
                return "Error: Unknown operation."
            }
        }
    }
}
