//
//  main.swift
//  Compiler
//
//  Created by Головаш Анастасия on 29.10.2020.
//

#if DEBUG
import Foundation

for test in testsCW {
    _ = compiler(code: test)
    Parser.adres = 0
    Parser.funcFlagsName = 0
    Parser.whileFlagsCurentName = 0
    Parser.whileFlagsUniqueName = 0
    Parser.variablesIdentifiers = [:]
    Parser.functionCalledIdentifiers = []
    Parser.functionDeclaredIdentifiers = [:]
    Parser.functionDefinedIdentifiers = []
    print("\n\n")
}

// 381
let code =
"""
// Functions declaration
int nMemberOfGeometricProgression(int n, int b1, int q);
int sumOfFirstNMembers(int n, int b1, int bn, int q);
int pow(int number, int degree);

// Main func
// Returns summa of first 7 members of geometric progression
int main() {
    int firsMember = 3;
    int denominator = 2;
    int sevensMember = nMemberOfGeometricProgression(7, firsMember, denominator);
    int sum = sumOfFirstNMembers(7, firsMember, sevensMember, denominator);
    return sum;
}

// Returns nth member of geometric progression
// n  - number of member
// b1 - first member
// q  - denominator
int nMemberOfGeometricProgression(int n, int b1, int q) {
    return b1 * pow(q, n - 1);
}

// Returns summa of first n members of geometric progression
// n  - number of member
// b1 - first member
// bn - nth member
// q  - denominator
int sumOfFirstNMembers(int n, int b1, int bn, int q) {
    int S;

    if (q < 2) {
        // (q = 1) - special case
        if (0 < q) S = b1 * n;
        // for q = 0
        else S = (bn * q - b1) / (q - 1);
    } else {
        // for q > 2
        S = (bn * q - b1) / (q - 1);
    }

    return S;
}

int pow(int n, int degree) {
    int result = 1;
    int i = degree;
    while (0 < i) {
        result = result * n;
        i = i - 1;
    }

    return result;
}
"""

let code1 =
"""
int main() {
    int firsMember = 3 + 4;
    int denominator = 2;
    int sevensMember = nMemberOfGeometricProgression(7, firsMember, denominator);
    int sum = sumOfFirstNMembers(7, firsMember, sevensMember, denominator);
    return sum;
}
"""

//_ = compiler(code: code1)

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
