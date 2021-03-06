//
//  TreePrinter.swift
//  Compiler
//
//  Created by Головаш Анастасия on 13.10.2020.
//

import Foundation

public protocol PrintableTreeNode {
    var childs: [PrintableTreeNode] { get }
    var content: String { get }
}

public final class TreePrinter {

    public func printTree(startingFrom root: PrintableTreeNode) -> String {
        return recursivePrintTree(startingFrom: root)
    }
}

private extension TreePrinter {

    func recursivePrintTree(startingFrom root: PrintableTreeNode,
                            prefix: String = "",
                            hasMoreSiblings: Bool = false) -> String {
        let pipe = root.childs.isEmpty ? "" : "_"
        var string = root.content + pipe
        let additionalPrefix = (String(repeating: " ", count: string.count - 1))
        let childContent = (root.childs.enumerated().map { index, childNode in
            let topPrefix: String = {
                let replacement = hasMoreSiblings ? "| " : "  "
                return prefix
                    .replacingOccurrences(of: "|-", with: replacement)
                    .replacingOccurrences(of: "|_", with: replacement)
            }()
            let childHasMoreSiblings = index < root.childs.count - 1
            return self.recursivePrintTree(startingFrom: childNode,
                                    prefix: topPrefix + additionalPrefix + (childHasMoreSiblings ? "|-" : "|_"),
                                    hasMoreSiblings: childHasMoreSiblings) }).joined(separator: "\n")
        string = prefix + string
        if root.childs.isEmpty == false {
            string.append("\n\(childContent)")
        }
        return string
    }
}


extension CodeBlock {
    var childs: [PrintableTreeNode] {
        return astNodes
    }
    
    var content: String {
        return "Block" + type
    }
    
}

extension Function {
    var childs: [PrintableTreeNode] {
        var result: [PrintableTreeNode] = identifier.arguments
        result.append(block)
        return result
    }
    
    var content: String {
        return "Defined: \(identifier.type) \(identifier.name)"
    }
    
}

extension IfStatement {
    
    var childs: [PrintableTreeNode] {
        if let secondBlock = elseBlock {
            return [condition, ifBlock, secondBlock]
        } else {
            return [condition, ifBlock]
        }
    }
    
    var content: String {
        "Condition"
    }
}

extension WhileStatement {
    var childs: [PrintableTreeNode] {
        return [condition, block]
    }
    
    var content: String {
        "While"
    }
}

extension Variable {
    var childs: [PrintableTreeNode] {
        return [value ?? "indefinite"]
    }
    
    var content: String {
        if type == "" {
            return "Var: \"\(identifier.name)\""
        } else {
            return "Block" + type + ": " + "Var: \"\(identifier.name)\""
        }
    }
}

extension ReturnStatement {
    var childs: [PrintableTreeNode] {
        return [node]
    }
    
    var content: String {
        if type == "" {
            return "ReturnStatement"
        } else {
            return "Block" + type + ": " + "ReturnStatement"
        }
    }
}

extension InfixOperation {
    var childs: [PrintableTreeNode] {
        if operation.rawValue == "/=" {
            return [rightNode]
        } else {
            return [leftNode, rightNode]
        }
    }
    
    var content: String {
        return "\"\(operation.rawValue)\""
    }
    
}

extension PrefixOperation {
    var childs: [PrintableTreeNode] {
        return [item]
    }
    
    var content: String {
        return "\"\(operation.rawValue)\""
    }
    
}

extension Number {
    
    var childs: [PrintableTreeNode] {
        if case let .numberInt(num, _) = number.token {
            return [num]
        } else if case let .numberFloat(num) = number.token {
            return [num]
         }
        return []
    }
    
    var content: String {
        if case let .numberInt(_, type) = number.token {
             switch type {
             case .decimal:
                return "int decimal"
             case .hex:
                return "int hex"
             }
        } else if case .numberFloat(_) = number.token {
            return "float"
         }
        return "Number"
    }
    
}

extension String: PrintableTreeNode {
    public var childs: [PrintableTreeNode] {
        return []
    }
    public
    var content: String {
        return self
    }

}

extension VariableIdentifier {
    public var childs: [PrintableTreeNode] {
        return []
    }
    public
    var content: String {
        return "Var: \"\(name)\""
    }
}

extension FunctionIdentifier {
    public var childs: [PrintableTreeNode] {
        return arguments
    }
    public
    var content: String {
        return "Declared: \(type) \"\(name)\""
    }
}

extension Argument {
    public var childs: [PrintableTreeNode] {
        return []
    }
    public
    var content: String {
        return "Argument: \(type) \(name)"
    }
}

extension FunctionCall {
    public var childs: [PrintableTreeNode] {
        return arguments
    }
    public
    var content: String {
        if type == "" {
            return "Called: \"\(name)\""
        } else {
            return "Block" + type + ": " + "Called: \"\(name)\""
        }
    }
}

extension Break {
    public var childs: [PrintableTreeNode] {
        return []
    }
    public
    var content: String {
        return "Break"
    }
    
}

extension Continue {
    public var childs: [PrintableTreeNode] {
        return []
    }
    public
    var content: String {
        return "Continue"
    }
    
}

extension Float {
    public var childs: [PrintableTreeNode] {
        return []
    }
    public   
    var content: String {
        return "\(self)"
    }
    
}

extension Int {
    public var childs: [PrintableTreeNode] {
        return []
    }
    public   
    var content: String {
        return "\(self)"
    }
    
}
