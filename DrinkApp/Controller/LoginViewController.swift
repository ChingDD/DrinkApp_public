//
//  LoginViewController.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/29.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var accountTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    var ButtonYofcurrentTetField = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        //通知中心觀察者設為自己
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //設定textField Delefate為自己
        for view in view.subviews{
            if view is UITextField{
                let textField = view as! UITextField
                textField.delegate = self
            }
        }
        
    }
    //MARK: - 自定義function
    func login(){
        let urlString = "https://favqs.com/api/session"
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Token token=4fdcff2ff98e1d8082b1928df1fc9fc3", forHTTPHeaderField: "Authorization")
        
        let body = User(user: UserInfo(login: accountTextField.text!, password: passwordTextField.text!))
        let loginbody = try! JSONEncoder().encode(body)
        urlRequest.httpBody = loginbody
        print(String(data: loginbody, encoding: .utf8)!)
        print("開始上傳")
        URLSession.shared.dataTask(with: urlRequest) {
            data, response, error
            in
            if let data{
                do{
                    print(String(data: data, encoding: .utf8)!)
                    let content = try JSONDecoder().decode(UserResponse.self, from: data)
                    print("登入後回應：\(content)")
                    UserDefaults.standard.set(content.userToken, forKey: "token")
                    
                    DispatchQueue.main.async {
                        if let tabBarController = self.storyboard?.instantiateViewController(identifier: "tabBarController"){
                            //因為tabBar前面沒有導航controller，所以這個方法會使後面的畫面變成卡片式，因此不用
                            //self.present(tabBarController, animated: true)
                            self.view.window?.rootViewController = tabBarController
                        }
                    }
                    
                }catch{
                    //登入失敗的error
                    print(error)
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do{
                        let loginError = try decoder.decode(UserError.self, from: data)
                        let alert = UIAlertController(title: "登入", message: loginError.message, preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "確定", style: .default)
                        alert.addAction(alertAction)
                        DispatchQueue.main.async {
                            self.present(alert, animated: true)
                        }
                    }catch{
                        print("解析錯誤失敗")
                    }
                }
            }
        }.resume()
    }

    @objc func keyboardWillShow(_ notification:Notification){
        if let keyboardFrame = notification.userInfo?[AnyHashable("UIKeyboardBoundsUserInfoKey")] as? NSValue{
            let visibleHeight = view.frame.height-keyboardFrame.cgRectValue.height
            if ButtonYofcurrentTetField > visibleHeight{
                let offSetY = ButtonYofcurrentTetField - visibleHeight
                UIView.animate(withDuration: 0.5) {
                    self.view.frame.origin.y = -offSetY
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    
    //MARK: - Target Action
    //登入按鈕
    @IBAction func userLogin(_ sender: Any) {
        login()
    }
    
    //按空白處收鍵盤
    @IBAction func clickView(_ sender: Any) {
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
extension LoginViewController:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        ButtonYofcurrentTetField = textField.frame.maxY
    }
}
