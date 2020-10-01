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
        // Do any additional setup after loading the view.
        
        // Try changing the first parameter to sumOrA to 0 and back to 1
        let code0 = """
        float main() {
              return (-10 / 4) / 2;
        }
        """
//
//        let code1 = """
//        float main() {
//            return 0xA3;
//        }
//        """
//
//        let code2 = """
//        int main() {
//            return 0xA4C;
//        }
//        """
//
//        let code3 = """
//        int main() {
//            return 8;
//
//        """
//
//        let code4 = """
//        float main() {
//            return 1.8
//        }
//        """
        
        let code = code0
        
        print("______ENTERED CODE______")
        print(code)
        
        let lexerResult = Lexer(code: code)
        let tokensStruct = lexerResult.tokensStruct
        
//        print(lexerResult.tokensTable)
        
        do {
            let node = Parser(tokensStruct: tokensStruct)
            let ast = try node.parse()
            let interpret = try ast.generatingAsmCode()
            
            print(interpret)
            
            var lines : [String] = []
            interpret.enumerateLines { (line, _) in
                lines.append(line)
            }
            
            let text = """


            #include <iostream>
            #include <string>
            #include <stdint.h>
            using namespace std;
            int main()
            {
                int b;
                __asm {
                    (lines[0])
                    (lines[1])
                }
                cout << b << endl;
            }
            
            """
            
            
            print("______AST STRUCT______")
            print(ast)
//            print(text)
            
            
        } catch let error {
            if let error = error as? Parser.Error {
                print(error.localizedDescription)
            }
        }
    }

    

}

