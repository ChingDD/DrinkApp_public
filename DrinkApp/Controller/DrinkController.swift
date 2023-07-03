//
//  DrinkController.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/12.
//

import Foundation
import UIKit

class DrinkController{
    static let shared = DrinkController()
    
    func fetchDrinks(collectionView:UICollectionView, from urlString:String, completion:@escaping (Result<[[Drink]],Error>) -> Void){
        if let url = URL(string: urlString){
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("Bearer key1rgSyzPr4pBAmu", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: urlRequest) {
                data, response, error
                in
                if let data{
                    do{
                        let result = try JSONDecoder().decode(DrinkBody.self, from: data)
                        let records = result.records
                        let drinks = self.getDrinks(records: records)
                        DispatchQueue.main.async {
                            collectionView.reloadData()
                        }
                        completion(.success(drinks))
                    }catch{
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    }
    
    func getDrinks(records:[Record])->[[Drink]]{
        var drinks1:[Drink] = []
        var drinks2:[Drink] = []
        var drinks3:[Drink] = []
        var drinks4:[Drink] = []
        var drinks5:[Drink] = []
        var drinks6:[Drink] = []
        for i in records{
            switch i.fields.category[0]{
            case Category.私藏古法茶.rawValue:
                drinks1.append(i.fields)
            case Category.鍋煮鮮奶茶.rawValue:
                drinks2.append(i.fields)
            case Category.鶴記凍飲，信心出品.rawValue:
                drinks3.append(i.fields)
            case Category.傳統復刻奶茶.rawValue:
                drinks4.append(i.fields)
            case Category.秘製鮮果茶.rawValue:
                drinks5.append(i.fields)
            default:
                drinks6.append(i.fields)
            }
        }
        return [drinks1,drinks2,drinks3,drinks4,drinks5,drinks6]
    }
}
