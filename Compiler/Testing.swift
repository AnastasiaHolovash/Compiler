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


// MARK: - Lab5

let testsLab5 = [code50, code51, code52, code53, code54, code55, code56]

//Error: Function 'simple' was not declar.
//    Line: 4  Place: 12
let code50 =
"""
int SOME(float b, int a);

int main() {
        
    int b = simple();
    b /= 5;
    return b;
}

int simple() {
    return 1;
}
"""

//Error: Function 'SOME' was not define.
//    Line: 6  Place: 11
let code51 =
"""
int SOME(float b, int a);

int main() {
    
    int simple();
    int b = simple();
    return SOME(3, 4);
}

int simple() {
    return 1;
}
"""

//Error: Conflicting arguments types for 'SOME'.
//    Line: 6  Place: 4
//Note: Previous declaration of 'SOME' was:
//    'int SOME(float b, int a);'

let code52 =
"""
int SOME(float b, int a);

int main() {
    int b = 22 < SOME(3, 4);
    return b;
}

int SOME() {
    return 1;
}
"""

//Error: Conflicting arguments types for 'SOME'.
//    Line: 6  Place: 4
//Note: Previous declaration of 'SOME' was:
//    'int SOME(float b, int a);'
let code53 =
"""
int SOME(float b, int a);

int main() {
    int b = 22 < SOME(10 / 2, 4);
    return b;
}

int SOME(int some1, int some2) {
    int newSome = some1 * some1;
    return newSome;
}
"""

//Error: Conflicting return types for 'SOME'.
//    Line: 6  Place: 6
//Note: Previous declaration of 'SOME' was:
//    'int SOME(float b, int a);'
let code54 =
"""
int SOME(float b, int a);

int main() {
    int b = 22 < SOME(10 / 2, 4);
    return b;
}

float SOME(float some1, int some2) {
    int newSome = some1 * some1;
    return newSome;
}
"""

//Error: Invalid call for function 'SOME'.
//    Line: 3  Place: 28
//NOTE: Declaration was:
//    'int SOME(float b, int a);'
let code55 =
"""
int SOME(float b, int a);

int main() {
    int b = 22 < SOME(10 / 2);
    return b;
}

int SOME(float some1, int some2) {
    int newSome = some1 * some1;
    return newSome;
}
"""

//Error: Function 'expression' was define before.
//    Line: 10  Place: 3
let code56 =
"""
int expression(float b, int a);

int expression(float b, int a){
    int result = -(b / -a) * 5 < 2;
    return result;
}

int main() {
    int b = 22 < expression(10, 2);
    return b;
}

int expression(float some1, int some2) {
    int newSome = some1 * some1;
    return newSome;
}
"""

//Error: A variable with name 'a' already exist.
//    Line: 7  Place: 14
let code556 =
"""
int SOME(int a);

int main() {
    int b = 22 < SOME(3);
    return b;
}

int SOME(int a) {
    int a = 22;
    return 1;
}
"""

// TRUE 100
let code57 =
"""
int function(int bigParameter) {
    int thousand = 1000;
    {
        if (thousand) thousand /= 10;
        if (bigParameter < thousand)
            bigParameter = - bigParameter * thousand;
    }
    return bigParameter;
}

int getGreater(int first, int sesond){
    if (first < sesond) return sesond;
    else return first;
    return 0;
}

int main() {
    int a = 100;
    int b = 10;

    return function(getGreater(a, b));
}
"""

// TRUE 24
let code58 =
"""
int main() {
    int multiply(int a, int b, int c, int d);

    int a = 0x1 * 500 / 10;
    if (a < 5) {
        a = multiply(1, 2, 3, 0);
    } else if (5 < a) {
        int multiply = multiply(1, 2, 3, 4);
        if (multiply) return multiply;
    } else {
        a = -multiply(1, 2, 3, 4);
    }
    return a;
}

int multiply(int a, int b, int c, int d) {
    int n = a * b * d * c;
    return n;
}
"""

// TRUE 1
let code59 =
"""
int linearVelocity(float period, int radius);
float getPi();

int main() {
    int b = 900;
    b /= 3;
    int result = linearVelocity(2.5, 6 / 3) < b;
    return result;
}

int linearVelocity(float T, int r) {
    int n = getPi() * 2 * r / T;
    return n;
}

float getPi() {
    return 3.14;
}
"""
