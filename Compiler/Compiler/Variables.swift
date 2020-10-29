//
//  Variables.swift
//  Compiler
//
//  Created by Головаш Анастасия on 27.10.2020.
//

import Foundation

var flagsName = 0

func getNextFlag() -> Int {
    flagsName += 1
    return flagsName
}

var identifiers: [Int : [String : Int]] = [:]
var adres: Int = 0

func getNextAdres() -> Int {
    adres += 4
    return adres
}

func getFirstBlockAdres() -> Int {
    return adres + 4
}
