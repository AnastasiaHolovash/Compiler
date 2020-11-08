//
//  main.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

#if DEBUG
import Foundation

//for test in testsLab1 {
//    compiler(code: test)
//    adres = 0
//}

let code =
"""
int main() {
    int b = 10;
    b = SOME(1, 5) / 5;
    return SOME(1, 1);
}
int SOME(float b, int a);
int SOME(float b, int a) {
    int c;
    return 2;
}
"""

_ = compiler(code: code)

#endif


#if !DEBUG
import SwiftWin32
import let WinSDK.CW_USEDEFAULT

@main
final class AppDelegate: ApplicationDelegate {
    
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]?) -> Bool {
        do {
            let code = try String(contentsOfFile: "4-05-Swift-IV-82-Holovash.txt", encoding: String.Encoding.utf8)
            let cppCode = compiler(code: code)
            try cppCode.write(toFile: "4-05-Swift-IV-82-Holovash.cpp", atomically: false, encoding: String.Encoding.utf8)
        } catch let error {
            print(error.localizedDescription)
        }
        return true
    }
}
#endif


func compiler(code: String) -> String {
    
    var cppCode = String()
    
    print("______ENTERED CODE______")
    print(code)
    
    do {
        /**
        Lexing
        */
        let lexerResult = try Lexer(code: code)
        let tokensStruct = lexerResult.tokensStruct
        
        print(lexerResult.tokensTable)
        
        /**
         Parsing
         */
        let node = Parser(tokensStruct: tokensStruct)
        let ast = try node.parse()
        
        print("______AST STRUCT______")
        let treePrinter = TreePrinter()
        let result = treePrinter.printTree(startingFrom: ast)
        print(result)
        
        /**
         Interpreting
         */
        let interpret = try ast.generatingAsmCode()
        
        var cpp : String = ""
        interpret.enumerateLines { (line, _) in
            cpp += "\n        " + line
        }
        
        cppCode = """
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
        
        print("______CPP CODE______")
        print(cppCode)
        
    } catch let error {
        if let error = error as? Parser.Error {
            print(error.localizedDescription)
        }
    }
    return cppCode
}
