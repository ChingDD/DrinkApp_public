//
//  PayTableViewController.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/23.
//

import UIKit

class PayTableViewController: UITableViewController {
    var savedCustomDrinks = [Field]()
    var savedCustomDrink:CustomDrink!
    var savedOrdersNumber = "0"
    @IBOutlet weak var totalPriceLabel: UILabel!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //讀出userDefault裡的訂單
        //將存在userDefault裡的訂購飲品及其數量讀出來
        if let savedDrinksData = UserDefaults.standard.data(forKey: "savedDrinks"),
           let savedCustomDrinks = try? JSONDecoder().decode([Field].self, from: savedDrinksData){
            self.savedCustomDrinks = savedCustomDrinks
            self.savedOrdersNumber = "\(savedCustomDrinks.count)"
            print("payPage：讀取savedOrders完畢")
        }
        
        //總價格
        var totalPrice = 0
        for savedCustomDrink in savedCustomDrinks{
            totalPrice += savedCustomDrink.fields.price * savedCustomDrink.fields.number
        }
        self.totalPriceLabel.text = "總價格: $\(totalPrice)"
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("payPage：viewWillAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //新方法
        print("payPage：開始跑viewWillDisappear")
        //當用戶直接在payPage更改數量，但未送出訂單，要跳出去繼續選購時，要儲存他們剛剛做的修改紀錄到userDefault裡
        let savedDrinksData = try! JSONEncoder().encode(savedCustomDrinks)
        UserDefaults.standard.set(savedDrinksData, forKey: "savedDrinks")
        
        //因為表格刪除後，要把數量回傳到上一頁，所以跑performSegue
        //準備跑performSegue
        print("payPage：開始跑viewWillDisappear的performSegue")
        self.performSegue(withIdentifier: "unwindToOrderPage", sender: nil)
        //會等上一頁的unwineSegue跑完後才會跑到下面
        print("payPage：跑完viewWillDisappear的performSegue")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("開始跑prepare")
    }
    
    @IBAction func changeOrderNumber(_ sender: UIStepper) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        print("point:\(point)")
        if let indexPath = tableView.indexPathForRow(at: point),
           let cell = tableView.cellForRow(at: indexPath) as? PaymentTableViewCell{
            print(indexPath)
            print(sender.value)
            cell.orderNumber.text = "\(Int(sender.value)) 杯"
            //fields要改var才能用
            savedCustomDrinks[indexPath.row].fields.number = Int(sender.value)

            //cell.priceLabel.text = "$\(savedCustomDrinks[indexPath.row].fields.price)"
            var totalPrice = 0
            for field in savedCustomDrinks{
                totalPrice = totalPrice + field.fields.price * field.fields.number
            }
            totalPriceLabel.text = "總價格: $\(totalPrice)"
        }
    }
    
    @IBAction func sendOrders(_ sender: UIButton) {
        
        //上傳Order
        let urlString = "https://api.airtable.com/v0/appoygpvH8Xg8qMnE/orderDrink"
        let order = Order(records: savedCustomDrinks)
        UploadOrderController.shared.uploadOrder(url: urlString, order: order) {
            result
            in
            switch result{
            case .success(let response):
                let alert = UIAlertController(title: "訂購", message: "訂購送出", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "確認", style: .default){_ in
                    
                    //新方法
                    //走到這邊表示要送出訂單，所以要將userDefault儲存的訂購飲品跟訂購飲品個數都刪掉
                    UserDefaults.standard.removeObject(forKey: "savedDrinks")
                    self.savedOrdersNumber = "0"
                    self.savedCustomDrinks = []
                    print("payPage：開始跑sendOrders的performSegue")
                    self.performSegue(withIdentifier: "unwindToOrderPage", sender: nil)
                    print("payPage：跑完sendOrders的performSegue")
                    
                }
                
                alert.addAction(alertAction)
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
                print("上傳成功後回傳的response：\(response)")
            case .failure(let error):
                print("上傳失敗回傳的response:\(error)")
            }
        }
        
        
    }
    
    
   
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  savedCustomDrinks.count != 0 ? savedCustomDrinks.count : 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //表示在特定的cell裡，該order的飲品是哪個
        let order = savedCustomDrinks[indexPath.row].fields
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTableViewCell", for: indexPath) as! PaymentTableViewCell
        //飲料名字
        cell.drinkName.text = order.name
        //大小甜度冰涼、個人加料
        if let topping = order.topping, let jelly = order.jelly{
            cell.customLabel.text = "\(order.size)/\(order.sugar)/\(order.ice)/\(topping)/\(jelly)"
        }else if let topping = order.topping{
            cell.customLabel.text = "\(order.size)/\(order.sugar)/\(order.ice)/\(topping)"
        }else if let jelly = order.jelly{
            cell.customLabel.text = "\(order.size)/\(order.sugar)/\(order.ice)/\(jelly)"
        }else{
            cell.customLabel.text = "\(order.size)/\(order.sugar)/\(order.ice)"
        }
        //飲料價格
        cell.priceLabel.text = "$\(order.price)"
        //飲料數量
        cell.orderNumber.text = "\(order.number)杯"
        cell.drinkAmountsStepper.value = Double(order.number)
        //特殊飲料的喜好選項
        if let upgradeMilkTea = order.upgradeMilkTea, let AddFreeBlackTeaJelly = order.isAddFreeBlackTeaJelly{
            cell.favoriteFlavorLabel.text = String("喜好選項: "+upgradeMilkTea+AddFreeBlackTeaJelly)
        }else if let upgradeMilkTea = order.upgradeMilkTea{
            cell.favoriteFlavorLabel.text = String("喜好選項: "+upgradeMilkTea)
        }else if let favoriteFlavor = order.favorite{
            cell.favoriteFlavorLabel.text = String("喜好選項: "+favoriteFlavor)
        }else{
            cell.favoriteFlavorLabel.text = ""
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

   
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //移除對應表格的飲品
        savedCustomDrinks.remove(at: indexPath.row)
        //這邊不用特別更新userDefault儲存的客製化飲品，只要將頁面滑掉，就會觸發viewWillDissapear，街著就會把savedCustomDrinks存到userDefault
        //更新表格
        tableView.deleteRows(at: [indexPath], with: .fade)
        //修正價格
        var totalPrice = 0
        for field in savedCustomDrinks{
            totalPrice = totalPrice + field.fields.price * field.fields.number
        }
        totalPriceLabel.text = "總價格: $\(totalPrice)"
        //更改飲品數量
        savedOrdersNumber = "\(savedCustomDrinks.count)"
    }
    
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
