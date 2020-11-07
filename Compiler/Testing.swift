//
//  Testing.swift
//  Compiler
//
//  Created by Головаш Анастасия on 14.10.2020.
//

import Foundation

// MARK: - Lab1

let testsLab1 = [code10, code11, code12, code13, code14, code15]

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

let testsLab2 = [code20, code21, code22, code23, code24, code25, code26, code27, code28]

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

let testsLab3 = [code30, code31, code32, code33, code34, code35, code36, code37, code38, code39]

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

// TRUE 0
let code39 = """
int main() {
    float first = 8.5;
    int second = 2 * first / 4;
    int third = 0x2 * -second;
    int answer = (third / 2) / -2 * 5 < 1;
    return answer;
}
"""



// MARK: - Lab4

let testsLab4 = [code40, code41, code42, code43, code44, code45, code46, code47]

// TRUE 50
let code40 =
"""
int main() {
    int a;
    {
        a = -100;
    }
    if (10 < 5) {
        a = 5;
    } else if (3 < 4) {
        if (0) {
            a = 1;
        } else {
            a = 0x1 * 500 / 10;
        }
    } else if (4 < 5) {
        a = 6;
    } else if (5 < 6) {
        a = 7;
    }
    return a;
}
"""

// TRUE 110
let code41 =
"""
int main() {
    int a = 7;
    {
        int test;
        int a;
        {
            if (a) a = 100;
        }
    }
    {
        int beta = 770 / a;
        return beta;
    }
    return a;
}
"""

// TRUE -25
let code42 =
"""
int main() {
    int a = 7;
    if (1) a = 10;
    if (3 < 0xA) {
        return -(100 / -a) * 5 / -2;
    } else {
        return a * a;
    }
    return a;
}
"""

//Error: A variable with name 'test' already exist.
//    Line: 8  Place: 17
let code43 =
"""
int main() {
    int test = 7;
    if (3 < 0xA) {
        return -2;
    } else {
        return test * test;
    }
    int test = 29;
    return test;
}
"""

//Error: Extected '('.
//    Line: 3  Place: 7
let code44 =
"""
int main() {
    int some = 7;
    if 3 < 0xA
        return -2;
    return some;
}
"""

//Error: Extected '{'.
//    Line: 4  Place: 8
let code45 =
"""
int main() {
    int some = 7;
    if (3 < 0xA)
        int mewVar = 33;
    return some;
}
"""

//Error: Extected '}'.
//    Line: 12  Place: 0
let code46 =
"""
int main() {
    int some = 7;
    if (3 < 0xA) {
        int mewVar = 33;
        {
            int some = 7;
            {
                int some = 7;
            }
        }
    return some;
}
"""

//Error: No such identifier: 'mewVar'.
//    Line: 7  Place: 13
let code47 =
"""
int main() {
    int some = 7;
    if (33) {
        {
            int mewVar = 33;
        }
        some = mewVar / 3;
    }
    return some;
}
"""

// Editional test
let code48 =
"""
int main() {
    int a = 5;
    int b = 404;

    if (b == a) b = 15;
    else if (b < a) return a;
    return b;
}
"""
