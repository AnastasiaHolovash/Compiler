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
    @discardableResult mutating func trimLeadingWhitespace() -> Int {
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
    func generatingAsmCode() throws -> String {
        return String(Int(self))
    }
}

extension Int: Node {
    
    func generatingAsmCode() throws -> String {
        
        return String(self)
    }
    
    func decToHex() throws -> String {
        return "0x" + String(format:"%02X", self)
    }
    
}

extension String: Node {
    func generatingAsmCode() throws -> String {
        guard identifiers[self] != nil else { 
            throw Parser.Error.unexpectedError
        }
        return self
    }
}

extension String {
    
    func hexToDec() -> UInt8 {
        return UInt8(self.replacingOccurrences(of: "0x", with: ""), radix: 16)!
    }
    
}


extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
