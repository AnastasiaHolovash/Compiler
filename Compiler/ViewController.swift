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
            float main(){ return 0xA2; }
        """
        print(code)
        
        let tokens = Lexer(code: code).tokens
        let tokensStruct = Lexer(code: code).tokensStruct
        
        
        for item in tokensStruct {
            print("\(item.token) - \(item.position.place)")
        }
        
        do {
            let node = Parser(tokens: tokens, tokensStruct: tokensStruct)
            let ast = try node.parse()
            let interpret = try ast.interpret()
            
            print(node)
            print(ast)
            print(interpret)
        } catch let error {
            if let error = error as? Parser.Error {
                print(error.localizedDescription)
            }
        }
    }

    

}

