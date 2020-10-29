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
        case unexpectedExpresion(position: (line: Int, place: Int))
        case variableAlreadyExist(String ,position: (line: Int, place: Int))
        case unexpectedError
        case unknownOperation(String ,position: (line: Int, place: Int))
        case incorrectIfStatement(position: (line: Int, place: Int))
        
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
                        Error: No such identifier: \'\(str)\'.
                            Line: \(line)  Place: \(place)
                       """
            case let .unexpectedExpresion(position: (line: line, place: place)):
                return """
                        Error: Unexpected expresion found.
                            Line: \(line)  Place: \(place)
                       """
            case let .variableAlreadyExist(str, position: (line: line, place: place)):
                return """
                        Error: A variable with name \'\(str)\' already exist.
                            Line: \(line)  Place: \(place)
                       """
            case .unexpectedError:
                return "Error: Unexpected error."
            case let .unknownOperation(str, position: (line: line, place: place)):
                return """
                        Error: Unknown operation: \'\(str)\'.
                            Line: \(line)  Place: \(place)
                       """
            case let .incorrectIfStatement(position: (line: line, place: place)):
                return """
                        Error: Incorrect if statement.
                            Line: \(line)  Place: \(place)
                       """
            }
        }
    }
    
    func getTokenPositionInCode() -> (line: Int, place: Int) {
        return tokensStruct[index - 1].position
    }
    
    // TODO: - implement one more getTokenPositionInCode for [index]
}
