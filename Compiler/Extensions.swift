//
//  Extensions.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

public extension String {
    //    returns a substring matching the given regular expression, but only if that substring is a prefix of the string
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
    //    removes all leading whitespace from a String
    mutating func trimLeadingWhitespace() {
        let i = startIndex
        while i < endIndex {
            guard CharacterSet.whitespacesAndNewlines
                .contains(self[i].unicodeScalars.first!) else {
                return
            }
            self.remove(at: i)
        }
    }
}

extension Sequence {
    func count(where: (Iterator.Element) -> Bool) -> Int {
        var cnt = 0
        for element in self {
            if `where`(element) {
                cnt += 1
            }
        }
        return cnt
    }
}

extension Float: Node {
    func interpret() throws -> String {
        return String(self)
    }
}

extension Int: Node {
    
    func interpret() throws -> String {
        
        return String(self)
    }
    
    func decToHex() throws -> String {
        return "0x" + String(format:"%02X", self)
    }
    
}

extension String: Node {
    func interpret() throws -> String {
        guard identifiers[self] != nil else { 
            throw Parser.Error.notDefined(self)
        }
        return self
    }
}

extension String {
    
    func hexToDec() -> UInt8 {
        return UInt8(self.replacingOccurrences(of: "0x", with: ""), radix: 16)!
    }
    
}
