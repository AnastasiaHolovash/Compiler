//
//  Lexer.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

/*
Then try to match a known regex against the prefix of our working code string,
 we add the token representation of that prefix to our list of tokens.
If a match was found, we remove the added prefix from our working code,
 if not, we are done, and can simply store the list of tokens as a property
 on our lexer instance.
*/
class Lexer: ThrowCastingError {
    
    var tokensStruct: [TokenStruct] = []
    var tokensTable = "\n\n______TOKENS TABLE______"
    var curentPosition: (line: Int, place: Int) = (line: 0, place: 0)
    
    private static func getNextPrefix(code: String) -> (regex: String, prefix: String)? {
        
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
    
    // ThrowCastingError delegate funcs
    func throwCastingError() throws {
        throw Parser.Error.expectedNumber(curentPosition.line, curentPosition.place)
    }
    
    func printingCastingPosition() {
        print("Type reduction position: Line: \(curentPosition.line) Position: \(curentPosition.place)")
    }
    
    init(code: String) {
        
        Token.delegate = self
        
        var code = code
        var curentPlace = code.trimLeadingWhitespace()
        
        while let next = Lexer.getNextPrefix(code: code) {
            let (regex, prefix) = next
            
            code = String(code[prefix.endIndex...])
            
            self.curentPosition = (line: 1, place: curentPlace)
            do {
                guard let tokenGeter = Token.tokenGeter[regex], let token = try tokenGeter(prefix) else {
                        fatalError("123")
                }
                tokensStruct.append(TokenStruct(token: token, position: (line: 1, place: curentPlace)))
                curentPlace += code.trimLeadingWhitespace()
                curentPlace += prefix.count
                tokensTable += "\n\(prefix) - \(token)"
                
            } catch {
                
            }
             
            

            
                        
            
        }
        tokensTable += "\n\n"
    }
}
