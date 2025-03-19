//
//  savedDrinkController.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/23.
//

import Foundation
import UIKit

class SavedDrinkController{
    static let shared = SavedDrinkController()
    //把儲存在雲端的order飲品抓下來(no use)
    func fetchSavedDrinks(tableView:UITableView?, from urlString:String, completion:@escaping (Result<[Field],Error>) -> Void){
        if let url = URL(string: urlString){
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("Bearer key1rgSyzPr4pBAmu", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: urlRequest) {
                data, response, error
                in
                if let data{
                    do{
                        let content = try JSONDecoder().decode(Order.self, from: data)
                        //let savedOrder = self.getSavedDrink(records: content.records)
                        let savedOrderFields = content.records
                        completion(.success(savedOrderFields))
                        DispatchQueue.main.async {
                            guard let tableView else {return}
                            tableView.reloadData()
                        }
                    }catch{
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    }
    
    func getSavedDrink(records:[Field])->[CustomDrink]{
        var savedOrder:[CustomDrink] = []
        for i in records{
            savedOrder.append(i.fields)
        }
        return savedOrder
    }
    
    
    
}
