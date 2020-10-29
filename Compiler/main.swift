//
//  main.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

#if DEBUG
import Foundation

for test in testsLab1 {
    compiler(code: test)
    adres = 0
}
#endif


#if !DEBUG
import SwiftWin32
import let WinSDK.CW_USEDEFAULT

@main
final class AppDelegate: ApplicationDelegate {
    
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]?) -> Bool {
        
        let code = try String(contentsOfFile: "4-07-Swift-IV-82-Danyliuk.txt", encoding: String.Encoding.windowsCP1251)
        compile(code: code)
        return true
    }
}
#endif


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
        
//            print("______ENTERED CODE______")
//            print(code)
        
//            print("\n______ASM CODE______")
//            print(interpret)
        print("______CPP CODE______")
        print(text)
        
        
    } catch let error {
        if let error = error as? Parser.Error {
            print(error.localizedDescription)
        }
    }
}
