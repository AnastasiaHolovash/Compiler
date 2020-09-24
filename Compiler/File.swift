//
//  File.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import Foundation

var identifiers: [String: FunctionDefinition] = [:]

protocol Node {
    func interpret() throws -> String
}



struct Block: Node {
    let nodes: [Node]
    
    func interpret() throws -> String {
        var codeASM = ""
        
        for item in nodes[0..<(nodes.endIndex - 1)] {
            codeASM += try item.interpret()
        }
        
        guard let last = nodes.last else {
            throw Parser.Error.expectedExpression
        }
        codeASM += try last.interpret()
        return codeASM
    }
}



//struct FunctionCall: Node {
//    let identifier: String
//
//    func interpret() throws -> String {
//        guard let definition = identifiers[identifier],
//            case let .function(function) = definition else {
//                throw Parser.Error.notDefined(identifier)
//        }
//
//        guard function.parameters.count == parameters.count else {
//            throw Parser.Error.invalidParameters(toFunction: identifier)
//        }
//
//        let paramsAndValues = zip(function.parameters, parameters)
//
//        // Temporarily add parameters to global index
//        try paramsAndValues.forEach { (name, node) in
////            guard identifiers[name] == nil else {
////                throw Parser.Error.alreadyDefined(name)
////            }
//            identifiers[name] = .variable(value: try node.interpret())
//        }
//        print(paramsAndValues)
//
//        let returnValue = try function.block.interpret()
//
//        // Remove parameter values from global index after use
//        paramsAndValues.forEach { (name, _) in
//            identifiers.removeValue(forKey: name)
//        }
//        return returnValue
//        return ""
//    }
//}

