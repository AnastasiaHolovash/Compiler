//
//  Testing.swift
//  Compiler
//
//  Created by Головаш Анастасия on 14.10.2020.
//

import Foundation

// MARK: - Lab1
let code10 = """
float main() {
      return 0xA3;
}
"""
let code11 = """
float main() {
      return 1.8
}
"""
let code12 = """
float main() {
        1.8;
}
"""
let code13 = """
float main() {
      return 8;

"""
//  true
let code14 = """
float main() {
      return 0xA4c;
}
"""
//  true
let code15 = """
float main() {
      return 1.8;
}
"""

// MARK: - Lab2
//  true
let code20 = """
float main() {
      return ((-4 / -(8 / (2 / 2))) / 1);
}
"""

//  true
let code21 = """
int main() {
    return -(6 / 3) / -(2.8 / 2) / 2;
}
"""

//  true
let code22 = """
int main() {
    return 0xA4C / -0x2;
}
"""

//  ERROR
let code23 = """
int main() {
    return (-16 / 4) -2;
}
"""
//  ERROR
let code24 = """
float main() {
    return 1.8 / -2
}
"""
//  ERROR
let code25 = """
int () {
    return (1.8 / -2) / 1;
}
"""
//  ERROR
let code26 = """
float main() {
    return (1.8 / +2) / 1;
}
"""
//  ERROR
let code27 = """
float main() {
    return (1.8 / -2;
}
"""

//  ERROR
let code28 = """
float main() {
    return (1 / -d) / 1
}
"""


// MARK: - Lab3

//        Error: Unexpected expresion found.
//            Line: 3  Place: 22
let code30 = """
int main() {
    int years = 19;
    years = years / 20;
    10 / 1 < -years;
}
"""


//        Error: Extected ';'.
//            Line: 5  Place: 13
let code31 = """
int main() {
    int y = 10 * 2;
    y = y / 2;
    int D = 19;
    return D = y;
}
"""

//        Error: A variable with name 'A' already exist.
//            Line: 3  Place: 9
let code32 = """
int some() {
    int A;
    int A = 100 / 2;
    int B = ((A / -(5 / (2 / 2))) * 1);
    return A / B;
}
"""

//        Error: Extected ')'.
//            Line: 4  Place: 17
let code33 = """
int some() {
    int some = 0xA;
    int b = -some;
    return b * -(1 > 10);
}
"""

//        Error: No such identifier: 'variable'.
//            Line: 3  Place: 12
let code34 = """
int some() {
    int A;
    A = 100 / variable;
    int B = ((A / -(5 / (2 / 2))) * 1);
    return A / B;
}
"""

//        Error: Extected 'return'.
//            Line: 4  Place: 0
let code35 = """
int main() {
    int some = 19;
    int some2 = 10 / 1 < -some;
}
"""

//        Error: Unknown declaration. Extected '=' or '()'
//            Line: 2  Place: 14
let code36 = """
int main() {
    int some  19;
    return some;
}
"""

// TRUE 10
let code37 = """
int some() {
    int some = 0xA;
    int b = -some;
    return b * -(1 < 10);
}
"""

// TRUE -5
let code38 = """
int some() {
    int A;
    A = 100 / 2;
    int B = ((A / -(5 / (2 / 2))) * 1);
    return A / B;
}
"""

// TRUE 1
let code39 = """
int main() {
    float first = 8.5;
    int second = 2 * first / 4;
    int third = 0x2 * -second;
    int answer = (third / 2) / -2 * 5 < 1;
    return answer;
}
"""
