//
//  uploadOrderController.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/21.
//

import Foundation

class UploadOrderController{
    static let shared = UploadOrderController()
    
    func uploadOrder(url:String, order:Order ,completion: @escaping(Result<Response,Error>)->Void){
        guard let url = URL(string: url)else{return}
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer key1rgSyzPr4pBAmu", forHTTPHeaderField: "Authorization")
        let updateBody = try! JSONEncoder().encode(order)
        print(String(data: updateBody, encoding: .utf8)!)
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
                    print(error)
                }
            }
        }.resume()
    }
}
