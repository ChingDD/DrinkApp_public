//
//  RegistViewController.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/29.
//

import UIKit

class RegistViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var ButtonYofcurrentTetField = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        //註冊通知中心為自己
        var notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow) , name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //原本這樣會報錯，說view的成員沒有delegate
        /*
         for view in view.subviews{
             if view is UITextField{
                 view.delegate = self
             }
         }
         */
    
        //將自己設為textField的delegate
        for view in view.subviews{
            if view is UITextField{
                let textField = view as! UITextField
                textField.delegate = self
            }
        }
        
        
    }
        
    //MARK: 自定義function
    //註冊
    // 定義一個名為 registUser 的函式
    func registUser(){
        // 設定 API 的 URL 字串
        let urlString = "https://favqs.com/api/users"
        // 建立 URL 物件
        let url = URL(string: urlString)!
        // 建立 URLRequest 物件，並設定 URL
        var urlRequest = URLRequest(url: url)
        // 設定 HTTP 方法為 POST
        urlRequest.httpMethod = "POST"
        // 設定 HTTP 標頭中的 Content-Type 為 application/json
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // 設定 HTTP 標頭中的 Authorization，用於驗證身分
        urlRequest.addValue("Token token=4fdcff2ff98e1d8082b1928df1fc9fc3", forHTTPHeaderField: "Authorization")
        
        // 建立 User 物件，並傳入使用者資訊
        let body = User(user: UserInfo(login: accountTextField.text!, email: emailTextField.text!, password: passwordTextField.text!))
        // 將 User 物件編碼成 JSON 格式的資料
        let postBody = try! JSONEncoder().encode(body)
        // 設定 HTTP 請求的主體
        urlRequest.httpBody = postBody
        
        // 使用 URLSession 執行異步的資料任務
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let data {
                // 如果有資料回傳，進行資料解析
                do {
                    // 將回傳的資料解碼成 UserResponse 物件
                    let content = try JSONDecoder().decode(UserResponse.self, from: data)
                    // 將解析後的使用者令牌儲存到 UserDefaults
                    UserDefaults.standard.set(content.userToken, forKey: "token")
                    // 印出解析後的內容
                    print(content)
                    // 印出註冊成功的訊息
                    print("註冊成功")
                    
                    DispatchQueue.main.async {
                        if let tabBarController = self.storyboard?.instantiateViewController(identifier: "tabBarController") {
                            // 將 tabBarController 設定為根視圖控制器
                            self.view.window?.rootViewController = tabBarController
                        }
                    }
                    
                } catch {
                    // 若解析失敗，印出錯誤訊息
                    print("註冊失敗：\(error)")
                    do {
                        // 建立 JSONDecoder 物件，並設定鍵解碼策略
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        // 將回傳的資料解碼成 UserError 物件
                        let registError = try decoder.decode(UserError.self, from: data)
                        // 建立警示視窗，顯示錯誤訊息
                        let alert = UIAlertController(title: "輸入有誤", message: registError.message, preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "確定", style: .default)
                        alert.addAction(alertAction)
                        DispatchQueue.main.async {
                            // 在主執行緒中顯示警示視窗
                            self.present(alert, animated: true)
                        }
                    } catch {
                        // 若解析失敗，印出錯誤訊息
                        print("錯誤解析失敗")
                    }
                }
            }
        }.resume() // 開始執行資料任務
    }

    
    //鍵盤彈起來
    @objc func keyboardWillShow(_ notification:Notification){
        //這個function在輸入文字後還會啟動一次
        print("keyboardWillShow啟動")
        if let keyboardFrame = notification.userInfo?[AnyHashable("UIKeyboardBoundsUserInfoKey")] as? NSValue{
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let visibleHeight = view.frame.height-keyboardHeight
            if ButtonYofcurrentTetField > visibleHeight{
                let offSetY = ButtonYofcurrentTetField - visibleHeight
                //self.view.frame.origin.y = -offSetY
                //MARK: - 問題 一開始談鍵盤時animate沒作用
                UIView.animate(withDuration: 0.5) {
                    print("UIView.animate作用")
                    self.view.frame.origin.y = -offSetY
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        UIView.animate(withDuration: 2) {
            self.view.frame.origin.y = 0
        }
    }
    
    
    //MARK: - Target Action
    //註冊確認鍵
    @IBAction func uploadRegist(_ sender: Any) {
        registUser()
    }
    
    //按空白處收鍵盤
    @IBAction func clickView(_ sender: UITapGestureRecognizer) {
        for view in view.subviews{
            if view is UITextField{
                view.resignFirstResponder()
            }
        }
    }
    
    //按return收鍵盤
    @IBAction func clickReturn(_ sender: Any) {
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - UITextFieldDelegate
extension RegistViewController:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing作用中")
        ButtonYofcurrentTetField = textField.frame.maxY
    }
}
