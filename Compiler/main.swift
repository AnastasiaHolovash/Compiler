//
//  main.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

#if DEBUG
import Foundation

//for test in testsLab6 {
//    _ = compiler(code: test)
//    Parser.adres = 0
//    Parser.funcFlagsName = 0
//    Parser.whileFlagsCurentName = 0
//    Parser.whileFlagsUniqueName = 0
//    Parser.variablesIdentifiers = [:]
//    Parser.functionCalledIdentifiers = []
//    Parser.functionDeclaredIdentifiers = [:]
//    Parser.functionDefinedIdentifiers = []
//    print("\n\n")
//}

let code =
"""
int nMemberOfGeometricProgression(int n, int b1, int q);
int sumOfFirstNMembers(int n, int b1, int bn, int q);

int main() {
    int firsMember = 3;
    int denominator = 2;
    int sevensMember = nMemberOfGeometricProgression(7, firsMember, denominator);
    int sum = sumOfFirstNMembers(7, firsMember, sevensMember, denominator);
    return = sum;
}

int nMemberOfGeometricProgression(int n, int b1, int q) {
    return b1 * pow(q, n - 1);
}

int sumOfFirstNMembers(int n, int b1, int bn, int q) {
    return (bn * q - b1) / (b1)
}

int pow(int number, int degree) {
    int result = 1;
    
    while (1 < degree) {
        result = result * number;
        degree = degree - 1;
    }

    return result;
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
            let code = try String(contentsOfFile: "6-05-Swift-IV-82-Holovash.txt", encoding: String.Encoding.utf8)
            let cppCode = compiler(code: code)
            try cppCode.write(toFile: "6-05-Swift-IV-82-Holovash.cpp", atomically: false, encoding: String.Encoding.utf8)
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
