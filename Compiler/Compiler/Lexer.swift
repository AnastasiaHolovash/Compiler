//
//  Lexer.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

// MARK: - Lexer
class Lexer: ThrowCastingError {
    
    var tokensStruct: [TokenStruct] = []
    var tokensTable = "\n______TOKENS TABLE______"
    var curentPosition: (line: Int, place: Int) = (line: 0, place: 0)
    
    private static func getNewPrefix(code: String) -> (regex: String, prefix: String)? {
        
        var keyValue: (key: String, value: ((String) throws -> Token?))?
        for (regex, generator) in Token.tokenGeter {
            
            if code.getPrefix(regex: regex) != nil {
                keyValue = (regex, generator)
            }
        }
        guard let regex = keyValue?.key,
            keyValue?.value != nil else {
                return nil
        }
        return (regex, code.getPrefix(regex: regex)!)
    }
    
    /// ThrowCastingError delegate funcs
    func throwCastingError() throws {
        throw Parser.Error.expectedNumber(position: curentPosition)
    }
    func unknownOperation(op: String) throws {
        throw Parser.Error.unknownOperation(op, position: curentPosition)
    }
    
    init(code: String) throws {
        
        Token.delegate = self
        var curentPlace = 0
        var curentLine = 1
        
//        code.enumerateLines { (lineConstant, _) throws in
        let splitedString = code.split(separator: "\n")
        try splitedString.forEach { (subString) in
            let lineConstant = String(subString)

            var line = lineConstant
            curentPlace = line.trimWhitespace()
            
            while let newPrefix = Lexer.getNewPrefix(code: line) {
                let (regex, prefix) = newPrefix
                
                line = String(line[prefix.endIndex...])
                
                self.curentPosition = (line: curentLine, place: curentPlace)
                
                guard let tokenGeter = Token.tokenGeter[regex], let token = try tokenGeter(prefix) else {
                        fatalError("")
                }
                self.tokensStruct.append(TokenStruct(token: token, position: (line: curentLine, place: curentPlace)))
                curentPlace += line.trimWhitespace()
                curentPlace += prefix.count
                self.tokensTable += "\n\(prefix) - \(token)"
                
            }
            
            curentLine += 1
        }
        tokensTable += "\n"
    }
}



