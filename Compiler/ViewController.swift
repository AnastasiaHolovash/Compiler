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

//        let code0 = """
//        float main() {
//              return ((-4 / -(8 / (2 / 2))) / 1);
//        }
//        """
//        //  true
//        let code1 = """
//        int main() {
//            return -(6 / 3) / -(2.8 / 2) / 2;
//        }
//        """
//        //  true
//        let code2 = """
//        int main() {
//            return 0xA4C / -0x2;
//        }
//        """
//
//        //  ERROR
//        let code3 = """
//        int main() {
//            return (-16 / 4) -2;
//        }
//        """
//        //  ERROR
//        let code4 = """
//        float main() {
//            return 1.8 / -2
//        }
//        """
//        //  ERROR
//        let code5 = """
//        int () {
//            return (1.8 / -2) / 1;
//        }
//        """
//        //  ERROR
//        let code6 = """
//        float main() {
//            return (1.8 / +2) / 1;
//        }
//        """
//        //  ERROR
//        let code7 = """
//        float main() {
//            return (1.8 / -2;
//        }
//        """
//
//        //  ERROR
//        let code8 = """
//        float main() {
//            return (1 / -d) / 1
//        }
//        """
        
        let code9 = """
        int main() {
            int years = 19;
            years = years / 20;
            10 / 1 < -years;
        }
        """
        
        let code10 = """
        int main() {
            float asw = 4;
            int some = 3;
            int booool = 1;
            int answer = asw / (some * booool);
            return answer;
        }
        """
        let code11 = """
        int main() {
            int years = 40 * 2;
            years = years / 2;
            int denysYears;
            return denysYears = years;
        }
        """
        let code12 = """
        int some() {
            int var = 100 / 2;
            int years = ((var / -(5 / (2 / 2))) * 1);
            int denysYears;
            return var / years;
        }
        """
        
        let code = code12
        
        print("______ENTERED CODE______")
        print(code)
        
        
        
        
        do {
            let lexerResult = try Lexer(code: code)
            let tokensStruct = lexerResult.tokensStruct
            
            print(lexerResult.tokensTable)
            
            let node = Parser(tokensStruct: tokensStruct)
            let ast = try node.parse()
            let interpret = try ast.generatingAsmCode()
            
//            var cpp : String = ""
//            interpret.enumerateLines { (line, _) in
//                cpp += line + "\n\t"
//            }
            
            let text = """
            #include <iostream>
            #include <string>
            #include <stdint.h>
            using namespace std;
            int main()
            {
                int b;
                __asm {
                    (cpp)
                }
                cout << b << endl;
            }
            
            """
            
            
            print("______AST STRUCT______")
            print(ast)
            
            print("______ENTERED CODE______")
            print(code)
            
            print("\n______ASM CODE______")
            print(interpret)
//            print("______CPP CODE______")
//            print(text)
            
            
        } catch let error {
            if let error = error as? Parser.Error {
                print(error.localizedDescription)
            }
        }
    }

    

}

