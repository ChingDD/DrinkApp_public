//
//  Drink.swift
//  DrinkApp
//
//  Created by JeffApp on 2023/6/7.
//

import Foundation

struct DrinkBody:Decodable{
    let records:[Record]
}

struct Record:Decodable{
    let fields:Drink
}

struct Drink:Decodable{
    let name:String
    let category:[String]
    let noCaffeine:String
    let image:[Image]?
    let M:Int?
    let L:Int?
    let options:[String]?
    let description:String?
    let recommendSugar:String
    let recommendIce:String
    let confidence:String
}

struct Image:Decodable{
    let url:URL
}




