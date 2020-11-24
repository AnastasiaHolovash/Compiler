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
    
    
    init(code: String) {
        
        Token.delegate = self
        var curentPlace = 0
        var curentLine = 1
        
        code.enumerateLines { (lineConstant, _) in
            
            var line = lineConstant
            curentPlace = line.trimWhitespace()
            
            while let newPrefix = Lexer.getNewPrefix(code: line) {
                let (regex, prefix) = newPrefix
                
                line = String(line[prefix.endIndex...])
                
                self.curentPosition = (line: curentLine, place: curentPlace)
                do {
                    guard let tokenGeter = Token.tokenGeter[regex], let token = try tokenGeter(prefix) else {
                            fatalError("")
                    }
                    self.tokensStruct.append(TokenStruct(token: token, position: (line: curentLine, place: curentPlace)))
                    curentPlace += line.trimWhitespace()
                    curentPlace += prefix.count
                    self.tokensTable += "\n\(prefix) - \(token)"
                } catch let error {
                    if let error = error as? Parser.Error {
                        print(error.localizedDescription)
                    }
                }
            }
            curentLine += 1
        }
        tokensTable += "\n"
    }
}
