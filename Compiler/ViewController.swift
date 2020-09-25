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
            int main(){ return 345; }
        """
        print(code)
        
//        let tokens = Lexer(code: code).tokens
        let lexerResult = Lexer(code: code)
        let tokensStruct = lexerResult.tokensStruct
        
        print(lexerResult.tokensTable)
//        for item in tokensStruct {
//            print("\(item.token) - \(item.position.place)")
//        }
        
        do {
            let node = Parser(tokensStruct: tokensStruct)
            let ast = try node.parse()
            let interpret = try ast.interpret()
            
            let text = """


            #include <iostream>
            #include <string>
            #include <stdint.h>
            using namespace std;
            int main()
            {
            \(interpret)
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

