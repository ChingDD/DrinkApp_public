//
//  UpdateController.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/28.
//

import Foundation

class UpdateController{
    static let shared = UpdateController()
    //在pay頁面更改數量後，將變動的飲品傳到後台(no use)
    func updateOrder(url:String, fields:[Field] ,completion: @escaping(Result<Response,Error>)->Void){
        guard let url = URL(string: url)else{return}
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer key1rgSyzPr4pBAmu", forHTTPHeaderField: "Authorization")
        print("fields：\(fields)")
        let order = Order(records: fields)
        let updateBody = try! JSONEncoder().encode(order)
        print("上傳的資料： "+String(data: updateBody, encoding: .utf8)!)
        urlRequest.httpBody = updateBody

        URLSession.shared.dataTask(with: urlRequest) {
            data, response, error
            in
            if let data{
                do{
                    let content = try JSONDecoder().decode(Response.self, from: data)
                    completion(.success(content))
                    print("上傳成功")
                }catch{
                    completion(.failure(error))
                    print("UpdateController上傳錯誤：\(error)")
                }
            }
        }.resume()
    }
}
