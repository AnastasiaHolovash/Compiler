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
class Lexer {
    let tokens: [Token]
    let tokensStruct: [TokenStruct]
    
    private static func getNextPrefix(code: String) -> (regex: String, prefix: String)? {
        
        var keyValue: (key: String, value: ((String) -> Token?))?
        
        for (regex, generator) in Token.tokenGeter {
            
            if code.getPrefix(regex: regex) != nil {
                keyValue = (regex, generator)
                
            }
        }
        
        guard let regex = keyValue?.key,
            keyValue?.value != nil else {
                return nil
        }
//        print("Value -> \(code.getPrefix(regex: regex)!)")
        
        return (regex, code.getPrefix(regex: regex)!)
    }
    
    init(code: String) {
        
        var code = code
        var curentPlace = code.trimLeadingWhitespace()
        var tokens: [Token] = []
        var tokensStruct: [TokenStruct] = []
        
        while let next = Lexer.getNextPrefix(code: code) {
            let (regex, prefix) = next
            
//            if let index = code.index(of: prefix) {
//                let distance = code.distance(from: code.startIndex, to: index)
//                curentPlace += distance
//            }
            
            code = String(code[prefix.endIndex...])
            
            
            guard let generator = Token.tokenGeter[regex],
                let token = generator(prefix) else {
                    fatalError()
            }
            
            tokens.append(token)
            
//            let prefixPlace = code.index(of: prefix)
//            curentPlace += code.distanceTo(prefixPlace)
            tokensStruct.append(TokenStruct(token: token, position: (line: 1, place: curentPlace)))
            curentPlace += code.trimLeadingWhitespace()
            curentPlace += prefix.count
        }
        self.tokens = tokens
        self.tokensStruct = tokensStruct
    }
}
