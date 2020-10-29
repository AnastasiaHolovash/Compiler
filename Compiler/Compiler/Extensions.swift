//
//  Extensions.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

extension String {
    
    /// Returns a substring matching the given regular expression.
    func getPrefix(regex: String) -> String? {
        let expression = try! NSRegularExpression(pattern: "^\(regex)", options: [])
        
        let range = expression.rangeOfFirstMatch(in: self,
                                                 options: [],
                                                 range: NSRange(location: 0,
                                                                length: self.utf16.count))
        if range.location == 0 {
            return (self as NSString).substring(with: range)
        }
        return nil
    }
    
    
    /// Removes all leading whitespace from a String.
    @discardableResult mutating func trimWhitespace() -> Int {
        let i = startIndex
        var counter = 0
        while i < endIndex {
            guard CharacterSet.whitespacesAndNewlines
                .contains(self[i].unicodeScalars.first!) else {
                return counter
            }
            self.remove(at: i)
            counter += 1
        }
        return 0
        
    }
    
    
    func hexToDec() -> UInt16 {
        return UInt16(self.replacingOccurrences(of: "0x", with: ""), radix: 16)!
    }
    
    
    func deletingSufix(_ sufix: String) -> String {
        guard self.hasSuffix(sufix) else { return self }
        return String(self.dropLast(sufix.count))
    }
    
}


extension Float: ASTnode {
    
    /// Interpreter func
    func generatingAsmCode() throws -> String {
        return String(Int(self))
    }
}


extension Int: ASTnode {
    
    /// Interpreter func
    func generatingAsmCode() throws -> String {
        return String(self)
    }
    
    
    /// Interpreter func
    func decToHex() throws -> String {
        return "0x" + String(format:"%02X", self)
    }
}

