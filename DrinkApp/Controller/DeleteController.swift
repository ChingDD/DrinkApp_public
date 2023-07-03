//
//  deleteController.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/29.
//

import Foundation

class DeleteController{
    static let shared = DeleteController()
    func deletData(url:String, removes:[Field]){
        var urlComponent = URLComponents(string: url)
        let queryItem = removes.map { URLQueryItem(name: "records[]", value: $0.id)  }
        urlComponent?.queryItems = queryItem
        if let url = urlComponent?.url{
            print(url.absoluteString)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "DELETE"
            urlRequest.setValue("Bearer key1rgSyzPr4pBAmu", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: urlRequest) {
                data, response, error
                in
                if let data{
                    print(String(data: data, encoding: .utf8)!)
                    do{
                        let content = try JSONDecoder().decode(Records.self, from: data)
                        print(content)
                    }catch{
                        print(error)
                    }
                }
            }.resume()
        }
    }
}
