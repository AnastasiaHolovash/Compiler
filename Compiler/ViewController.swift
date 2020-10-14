//
//  ViewController.swift
//  Compiler
//
//  Created by Головаш Анастасия on 23.09.2020.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let code = code10

        compiler(code: code)
        
    }

    
    func compiler(code: String) {
        
        print("______ENTERED CODE______")
        print(code)
        
        do {
            let lexerResult = try Lexer(code: code)
            let tokensStruct = lexerResult.tokensStruct
            
            print(lexerResult.tokensTable)
            
            let node = Parser(tokensStruct: tokensStruct)
            let ast = try node.parse()
            let interpret = try ast.generatingAsmCode()
            
            var cpp : String = ""
            interpret.enumerateLines { (line, _) in
                cpp += "\n        " + line
            }
            
            let text = """
            #include <iostream>
            #include <string>
            #include <stdint.h>
            using namespace std;
            int main()
            {
                int b;
                _asm {
            \(cpp)
                }
                cout << "Answer: " << b << endl;
            }
            
            """
            
            
            print("______AST STRUCT______")
//            print(ast)
            let treePrinter = TreePrinter()
            let result = treePrinter.printTree(startingFrom: ast)
            print(result)
            
            print("______ENTERED CODE______")
            print(code)
            
            print("\n______ASM CODE______")
            print(interpret)
            print("______CPP CODE______")
            print(text)
            
            
        } catch let error {
            if let error = error as? Parser.Error {
                print(error.localizedDescription)
            }
        }
    }

}

