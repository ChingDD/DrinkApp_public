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
    func registUser(){
        let urlString = "https://favqs.com/api/users"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Token token=4fdcff2ff98e1d8082b1928df1fc9fc3", forHTTPHeaderField: "Authorization")
        
        let body = User(user: UserInfo(login: accountTextField.text!, email: emailTextField.text!, password: passwordTextField.text!))
        let postBody = try! JSONEncoder().encode(body)
        urlRequest.httpBody = postBody
        URLSession.shared.dataTask(with: urlRequest) {
            data, response, error
            in
            if let data{
                do{
                    let content = try JSONDecoder().decode(UserResponse.self, from: data)
                    UserDefaults.standard.set(content.userToken, forKey: "token")
                    print(content)
                    print("註冊成功")
                    
                    DispatchQueue.main.async {
                        if let tabBarController = self.storyboard?.instantiateViewController(identifier: "tabBarController"){
                            //因為tabBar前面沒有導航controller，所以這個方法會使後面的畫面變成卡片式，因此不用
                            //self.present(tabBarController, animated: true)
                            self.view.window?.rootViewController = tabBarController
                        }
                    }
                    
                }catch{
                    //這是註冊失敗時回傳的error
                    print(error)
                    do{
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let registError = try decoder.decode(UserError.self, from: data)
                        let alert = UIAlertController(title: "輸入有誤", message: registError.message, preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "確定", style: .default)
                        alert.addAction(alertAction)
                        DispatchQueue.main.async {
                            self.present(alert, animated: true)
                        }
                    }catch{
                        print("錯誤解析失敗")
                    }
                }
            }
        }.resume()
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
