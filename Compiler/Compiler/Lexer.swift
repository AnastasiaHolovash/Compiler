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


struct TokenStruct {
    let token: Token
    let position: (line: Int, place: Int)
}


protocol ThrowCastingError {
    func throwCastingError() throws
    func unknownOperation(op: String) throws
}


// MARK: - Token
enum Token: Equatable {
    
    case numberFloat(Float)
    case numberInt(Int, Type)
    case int
    case float
    case identifier(String)
    case parensOpen
    case parensClose
    case `return`
    case curlyOpen
    case curlyClose
    case semicolon
    // Lab 2 edition
    case unaryOperation(UnaryOperator)
    case binaryOperation(BinaryOperator)
    // Lab 3 edition
    case equal
    
    static var delegate : ThrowCastingError?
    
    static var tokenGeter: [String : (String) throws -> Token?] {
        return [
            "^(^0[xX][0-9a-fA-F]+)|^(^[0-9]+\\.[0-9]+)|^([0-9]+)": {
                if $0.contains(".") {
                    guard let num = Float($0) else {
                        try delegate?.throwCastingError()
                        throw Parser.Error.unexpectedError
                    }
                    return .numberFloat(num)
                } else if $0.contains("x") || $0.contains("X") {
                    let some = $0.hexToDec()
                    return .numberInt(Int(some), .hex)
                } else {
                    return .numberInt(Int($0)!, .decimal)
                }
            },
            
            "[a-zA-Z_$][a-zA-Z_$0-9]*": {
                guard $0 != "int" else {
                    return .int
                }
                guard $0 != "float" else {
                    return .float
                }
                guard $0 != "return" else {
                    return .return
                }
                return .identifier($0)
            },
            
            "\\*|\\/|\\+|\\-|\\<": {
                if $0 == "/" {
                    return .binaryOperation(BinaryOperator(rawValue: $0)!)
                } else if $0 == "*" {
                    return .binaryOperation(BinaryOperator(rawValue: $0)!)
                } else if $0 == "<" {
                    return .binaryOperation(BinaryOperator(rawValue: $0)!)
                } else if $0 == "-" {
                    return .unaryOperation(UnaryOperator(rawValue: $0)!)
                } else {
                    try delegate?.unknownOperation(op: $0)
                    throw Parser.Error.unexpectedError
                }
            },
            "\\=": { _ in .equal },
            "\\(": { _ in .parensOpen },
            "\\)": { _ in .parensClose },
            "\\{": { _ in .curlyOpen },
            "\\}": { _ in .curlyClose },
            "\\;": { _ in .semicolon }
        ]
    }
}


// MARK: - Type
enum Type {
    case decimal
    case hex
}


// MARK: - Binary Operator
enum BinaryOperator: String {
    
    case divide = "/"
    case multiply = "*"
    case isLessThan = "<"
    
    var precedence: Int {
        switch self {
        case .divide:
            return 20
        case .multiply:
            return 20
        case .isLessThan:
            return 10
        }
    }
}


// MARK: - Unary Operator
enum UnaryOperator: String {

    case minus = "-"
    
    var precedence: Int {
        switch self {
        case .minus:
            return 30
        }
    }
}
