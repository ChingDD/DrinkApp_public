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
    // 定義一個名為 fetchDrinks 的函式，接受一個 UICollectionView、一個 URL 字串 urlString 和一個 completion block，用於異步處理網路請求的結果。
    func fetchDrinks(collectionView: UICollectionView, from urlString: String, completion: @escaping (Result<[[Drink]], Error>) -> Void) {
        // 將傳入的 urlString 轉換成 URL 對象
        if let url = URL(string: urlString) {
            // 創建一個 URLRequest 對象，並設定它的 URL 和一個 Authorization 標頭，用於進行 API 請求
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("Bearer key1rgSyzPr4pBAmu", forHTTPHeaderField: "Authorization")
            
            // 使用 URLSession 創建一個 data task，並進行網路請求
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                // 當網路請求完成後，進入這個 completion block
                if let data = data {
                    do {
                        // 使用 JSONDecoder 將網路返回的 data 解碼成 DrinkBody 對象
                        let result = try JSONDecoder().decode(DrinkBody.self, from: data)
                        // 從解碼後的 DrinkBody 對象中獲取 records 屬性
                        let records = result.records
                        // 使用 getDrinks 函式將 records 整理成以不同類別為組的二維陣列
                        let drinks = self.getDrinks(records: records)
                        // 在主線程中重新載入 collectionView
                        DispatchQueue.main.async {
                            collectionView.reloadData()
                        }
                        // 調用 completion block，將整理後的 drinks 作為成功的結果回傳
                        completion(.success(drinks))
                    } catch {
                        // 如果解碼出現錯誤，調用 completion block，將錯誤回傳
                        completion(.failure(error))
                    }
                }
            }.resume() // 開始執行 data task
        }
    }

    // 定義一個名為 getDrinks 的函式，接受一個 Record 類型的陣列 records，將 records 根據類別進行分組，並返回分組後的二維陣列
    func getDrinks(records: [Record]) -> [[Drink]] {
        // 創建不同類別的空陣列，用於後續分組
        var drinks1: [Drink] = []
        var drinks2: [Drink] = []
        var drinks3: [Drink] = []
        var drinks4: [Drink] = []
        var drinks5: [Drink] = []
        var drinks6: [Drink] = []

        // 遍歷 records 陣列，根據每個 Record 對象的 category 屬性進行分類，將相同類別的 Drink 對象添加到相應的陣列中
        for i in records {
            switch i.fields.category[0] {
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

        // 將分組後的陣列以二維陣列的形式返回
        return [drinks1, drinks2, drinks3, drinks4, drinks5, drinks6]
    }

}
