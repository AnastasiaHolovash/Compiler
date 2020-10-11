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
        
        case expectedNumber(position: (line: Int, place: Int))
        case expectedIdentifier(position: (line: Int, place: Int))
        case expectedExpression(position: (line: Int, place: Int))
        case expectedNumberType(String ,position: (line: Int, place: Int))
        case expected(String, position: (line: Int, place: Int))
        case incorrectDeclaration(position: (line: Int, place: Int))
        case noSuchIdentifier(String, position: (line: Int, place: Int))
        case unexpectedError
        case unknownOperation
        
        var errorDescription: String? {
            switch self {
            case let .expectedNumber(position: (line: line, place: place)):
                return """
                        Error: Expected number.
                            Line: \(line)  Place: \(place)
                       """
            case let .expectedIdentifier(position: (line: line, place: place)):
                return """
                        Error: Expected identifier.
                            Line: \(line)  Place: \(place)
                       """
            case let .expectedExpression(position: (line: line, place: place)):
                return """
                        Error: Expression expected.
                            Line: \(line)  Place: \(place)
                        """
            case let .expectedNumberType(str, position: (line: line, place: place)):
                return """
                        Error: Extected number type \(str).
                            Line: \(line)  Place: \(place)
                       """
            case let .expected(str, position: (line: line, place: place)):
                return """
                        Error: Extected \'\(str)\'.
                            Line: \(line)  Place: \(place)
                       """
            case let .incorrectDeclaration(position: (line: line, place: place)):
                return """
                        Error: Unknown declaration. Extected '=' or '()'
                            Line: \(line)  Place: \(place)
                        """
            case let .noSuchIdentifier(str, position: (line: line, place: place)):
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
    
    func getTokenPositionInCode() -> (line: Int, place: Int) {
        return tokensStruct[index - 1].position
    }
}
