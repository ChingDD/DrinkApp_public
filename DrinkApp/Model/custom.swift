//
//  custom.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/18.
//

import Foundation

enum Custom:String,CaseIterable{
    case 大小
    case 甜度
    case 冰量
    case 鶴記製凍公司出品！
    case 加料看這邊！
    case 擇你所愛
    case 鮮奶茶系列限定
}

struct CustomDrink:Codable{
    var name:String
    var size:String
    var sugar:String
    var ice:String
    var jelly:String?
    var topping:String?
    var favorite:String?
    var upgradeMilkTea:String?
    var isAddFreeBlackTeaJelly:String?
    var number:Int
    var price:Int
}

//POST/Patch資料時decode JSON的結構
struct Order:Codable{
    let records:[Field]
}
struct Field:Codable{
    var id:String?
    var fields:CustomDrink
}

//Patch資料後decode 回傳資料JSON的結構
struct Response:Codable{
    let records:[Info]
}
struct Info:Codable{
    let id:String
    let createdTime:String
}

//刪除資料時decode JSON的結構
struct Records:Codable{
    let records:[deleteResponse]
}

struct deleteResponse:Codable{
    //deleted的型別打字串會錯
    let deleted:Bool
    let id:String
}
