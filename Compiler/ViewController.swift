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

        
        let code =
"""
int main() {
    int a;
    {
        a = 100;
    }
    if (1 < 5) {
        if (0) {
            a = 1;
        } else {
            a = 500 / 10;
        }
    } else if (3 < 4) {
        a = 5;
    } else if (4 < 5) {
        a = 6;
    } else if (5 < 6) {
        a = 7;
    }
    return a;
}
"""
        let code0 =
"""
int main() {
    int a = 7;
    {
        int test;
        int a;
        {
            a = 100;
        }
    }
    {
        int beta = 77 / a;
    }
    return a;
}
"""
        let code1 =
"""
int main() {
    int a = 7;
    if (1) a = 10;
    if (3 < 8) return 100;
    return a;
}
"""
        compiler(code: code1)
        
    }

    
    func compiler(code: String) {
        
        print("______ENTERED CODE______")
        print(code)
        
        
        do {
            let lexerResult = try Lexer(code: code)
            let tokensStruct = lexerResult.tokensStruct
            
//            print(lexerResult.tokensTable)
            
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

