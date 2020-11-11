//
//  main.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

#if DEBUG
import Foundation

//for test in testsLab5 {
//    _ = compiler(code: test)
//    Parser.adres = 0
//    Parser.flagsName = 0
//    Parser.functionCalledIdentifiers = []
//    Parser.functionDeclaredIdentifiers = [:]
//    Parser.functionDefinedIdentifiers = []
//    print("\n\n")
//}

let code =
"""
int SOME(int a);

int main() {
    if (1) SOME(3);
    else SOME(5);
    int b = 22 < SOME(3);
    return b;
}

int SOME(int a) {
    a = 22;
    return 1;
}
"""

_ = compiler(code: code59)

#endif


#if !DEBUG
import SwiftWin32
import let WinSDK.CW_USEDEFAULT

@main
final class AppDelegate: ApplicationDelegate {
    
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]?) -> Bool {
        do {
            let code = try String(contentsOfFile: "5-05-Swift-IV-82-Holovash.txt", encoding: String.Encoding.utf8)
            let cppCode = compiler(code: code)
            try cppCode.write(toFile: "5-05-Swift-IV-82-Holovash.cpp", atomically: false, encoding: String.Encoding.utf8)
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
        let lexerResult = Lexer(code: code)
        let tokensStruct = lexerResult.tokensStruct
        
//        print(lexerResult.tokensTable)
        
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
                call _main
                jmp _return\(cpp)

                _return:
                mov b, eax\n
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
