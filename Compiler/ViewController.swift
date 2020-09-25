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
        let code = """
        float main() {
            return 1.8;
        }
        """
//        print(code)
        
        let lexerResult = Lexer(code: code)
        let tokensStruct = lexerResult.tokensStruct
        
        print(lexerResult.tokensTable)
        
        do {
            let node = Parser(tokensStruct: tokensStruct)
            let ast = try node.parse()
            let interpret = try ast.generatingAsmCode()
            
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
                    \(lines[0])
                    \(lines[1])
                }
                cout << b << endl;
            }
            
            """
            
            
            print(node)
            print(ast)
            print(text)
            
            
        } catch let error {
            if let error = error as? Parser.Error {
                print(error.localizedDescription)
            }
        }
    }

    

}

