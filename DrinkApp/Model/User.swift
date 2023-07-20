//
//  Regist.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/29.
//

import Foundation

struct User:Codable{
    let user:UserInfo
}

struct UserInfo:Codable{
    let login:String
    var email:String?
    let password:String
}

struct UserResponse:Codable{
    let userToken:String
    let login: String
    

    enum CodingKeys:String,CodingKey{
        case userToken = "User-Token"   //他會使let userToken在coding時變成let User-Token，如此就會符合抓API的條件
        case login
    }
}

struct UserError:Codable{
    let errorCode:Int
    let message:String
}
