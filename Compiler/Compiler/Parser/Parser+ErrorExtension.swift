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
        
        case invalidFunctionCall(String, previousDeclaration: String, position: (line: Int, place: Int))
        case functionWasntDeclar(String, position: (line: Int, place: Int))
        case functionWasntDefine(String, position: (line: Int, place: Int))
        case functionWasDefineBefore(String, position: (line: Int, place: Int))
        case conflictingArgumentsTypesFor(String, previousDeclaration: String, position: (line: Int, place: Int))
        case conflictingReturnTypesFor(String, previousDeclaration: String, position: (line: Int, place: Int))
        case funcMainMustBeDefine
        case incorrectDeclarationInGlobalScope(String, position: (line: Int, place: Int))
        
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
            case let .invalidFunctionCall(str, previousDeclaration, position: (line: line, place: place)):
                return """
                        Error: Invalid call for function \'\(str)\'.
                            Line: \(line)  Place: \(place)
                        NOTE: Declaration was:
                            \'\(previousDeclaration)\'
                       """
            case let .functionWasntDeclar(str, position: (line: line, place: place)):
                return """
                        Error: Function \'\(str)\' was not declar.
                            Line: \(line)  Place: \(place)
                       """
            case let .functionWasntDefine(str, position: (line: line, place: place)):
                return """
                        Error: Function \'\(str)\' was not define.
                            Line: \(line)  Place: \(place)
                       """
            case let .functionWasDefineBefore(str, position: (line: line, place: place)):
                return """
                        Error: Function \'\(str)\' was define before.
                            Line: \(line)  Place: \(place)
                       """
            case let .conflictingArgumentsTypesFor(str, previousDeclaration, position: (line: line, place: place)):
                return """
                        Error: Conflicting arguments types for \'\(str)\'.
                            Line: \(line)  Place: \(place)
                        Note: Previous declaration of \'\(str)\' was:
                            \'\(previousDeclaration)\'
                       """
            case let .conflictingReturnTypesFor(str, previousDeclaration, position: (line: line, place: place)):
                return """
                        Error: Conflicting return types for \'\(str)\'.
                            Line: \(line)  Place: \(place)
                        Note: Previous declaration of \'\(str)\' was:
                            \'\(previousDeclaration)\'
                       """
            case .funcMainMustBeDefine:
                return "Error: Func \'main\' must be define."
            case let .incorrectDeclarationInGlobalScope(str, position: (line: line, place: place)):
                return """
                        Error: Declaration \'\(str)\' in global scope.
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
