//
//  CustomTableViewController.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/17.
//

import UIKit

class CustomTableViewController: UITableViewController {

    
    @IBOutlet var sizeButton: [UIButton]!
    @IBOutlet var sugarLevelButton: [UIButton]!
    @IBOutlet var iceLevelButton: [UIButton]!
    @IBOutlet var tenDollarJellyButton: [UIButton]!
    @IBOutlet var fifteenDollarJellyButton: [UIButton]!
    @IBOutlet var toppingButton: [UIButton]!
    @IBOutlet var optionalButton: [UIButton]!
    @IBOutlet weak var freeBlackTeaJellySwitch: UISwitch!
    @IBOutlet weak var milkTeaCell: UITableViewCell!
    @IBOutlet weak var totalPriceLabel: UILabel!
    var VC1:OrderViewController?
    var selectedJellyBtn:UIButton!
    var selectedToppingBtn:UIButton!
    var drink:Drink!
    var customDrink:CustomDrink = CustomDrink(name: "", size: "", sugar: "", ice: "", jelly: nil, topping: nil, favorite:  nil, upgradeMilkTea: nil, isAddFreeBlackTeaJelly: nil, number: 0, price: 0)
    var costomDrinks:[Field] = []
    
    //不能用savedOrder儲存選擇好的飲料，因為每一次打開這個頁面，savedOrder都會變空的[]。所以存的東西會不見
    var savedOrder:Order!
    var totalPrice = 0
    var drinkPrice = 0{
        didSet{ updatePrice() }
    }
    var jellyPrice = 0{
        didSet { updatePrice() }
    }
    var toppingPrice = 0{
        didSet{ updatePrice() }
    }
    var milkTeaUpgradePrice = 0{
        didSet{ updatePrice() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationTitle()
        updateUI(drink:drink)
        customDrink.name = drink.name
        updatePrice()
        //將存在userDefault裡的order讀出來
        if let savedDrinksData = UserDefaults.standard.data(forKey: "savedDrinks"),
           let savedDrinks = try? JSONDecoder().decode([Field].self, from: savedDrinksData){
            self.costomDrinks = savedDrinks
            print("讀取savedOrder完畢")
        }
        
    }

    func updateNavigationTitle(){
        //為了只在此頁設定title，所以特別在此頁前面加navigationCOntroller
        title = drink.name
        //保持navigation bar顯示
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        //字體顏色是深綠色
        navigationBarAppearance.backgroundColor = UIColor(named: "Color4")
        //保持字體是30
        let attributeFont = UIFont.boldSystemFont(ofSize: 30)
        navigationBarAppearance.titleTextAttributes = [.font:attributeFont]
        //保持字的位置
        navigationBarAppearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 5)
        //捲的過程都保持以上設定
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    }
    
    func updatePrice(){
        totalPrice = drinkPrice+jellyPrice+toppingPrice+milkTeaUpgradePrice
        totalPriceLabel.text = "$\(totalPrice)"
        customDrink.price =  totalPrice
    }
    
    func updateUI(drink:Drink){
        //判斷有無大小杯的選項
        if drink.M==nil{
            sizeButton[0].isEnabled = false
            sizeButton[1].isSelected = true
        }else if drink.L==nil{
            sizeButton[1].isEnabled = false
            sizeButton[0].isSelected = true
        }
        //愛你所擇部分
        for btn in optionalButton{
            btn.isEnabled = false
        }
        if drink.name == "鶴記茶凍奶茶"{
            optionalButton[0].isEnabled = true
            optionalButton[1].isEnabled = true
//            optionalButton[0].configuration?.baseBackgroundColor = .yellow
//            optionalButton[0].isSelected = true
        }else if drink.name == "鶴記鴛鴦凍奶茶"{
            optionalButton[2].isEnabled = true
            optionalButton[3].isEnabled = true
//            optionalButton[2].configuration?.baseBackgroundColor = .yellow
//            optionalButton[2].isSelected = true
        }else if drink.name == "鶴記紅茶鮮豆奶"{
            optionalButton[4].isEnabled = true
            optionalButton[5].isEnabled = true
            optionalButton[6].isEnabled = true
//            optionalButton[4].configuration?.baseBackgroundColor = .yellow
//            optionalButton[4].isSelected = true
        }
  
        //鮮奶茶限定
        if drink.name.contains("那提") || drink.name.contains("鶴記紅茶鮮豆奶"){
            print("進到鮮奶茶區段")
            freeBlackTeaJellySwitch.isOn = false
            freeBlackTeaJellySwitch.isEnabled = false
            milkTeaCell.isUserInteractionEnabled = true
           
        }else{
            print("進到非鮮奶茶區段")
            freeBlackTeaJellySwitch.isOn = false
            freeBlackTeaJellySwitch.isEnabled = false
            milkTeaCell.isUserInteractionEnabled = false
        }
        
    }
    //MARK: - Target Action
    @IBAction func chooseSize(_ sender: UIButton) {
        for button in sizeButton{
            button.configuration?.baseBackgroundColor = .white
            button.isSelected = false
        }
        
        sender.configuration?.baseBackgroundColor = .yellow
        sender.isSelected = true
        if sender.titleLabel?.text == "M"{
            customDrink.size = Size.m.rawValue
            drinkPrice = drink.M!
        }else{
            customDrink.size = Size.l.rawValue
            drinkPrice = drink.L!
        }
    }
    
    @IBAction func chooseSugar(_ sender: UIButton) {
        for button in sugarLevelButton{
            button.configuration?.baseBackgroundColor = .white
            button.isSelected = false
        }
        
        sender.configuration?.baseBackgroundColor = .yellow
        sender.isSelected = true
        switch sender.titleLabel?.text{
        case "100%": customDrink.sugar = SugarLevel.全糖.rawValue
        case "70%": customDrink.sugar = SugarLevel.少糖.rawValue
        case "50%": customDrink.sugar = SugarLevel.半糖.rawValue
        case "30%": customDrink.sugar = SugarLevel.微糖.rawValue
        case "10%": customDrink.sugar = SugarLevel.一分糖.rawValue
        case "0%": customDrink.sugar = SugarLevel.無糖.rawValue
        default: break
        }

    }
    
    @IBAction func chooseIce(_ sender: UIButton) {
        for button in iceLevelButton{
            button.configuration?.baseBackgroundColor = .white
            button.isSelected = false
        }
        
        sender.configuration?.baseBackgroundColor = .yellow
        sender.isSelected = true
        
        switch sender.titleLabel?.text{
        case "100%": customDrink.ice = IceLevel.正常.rawValue
        case "70%": customDrink.ice = IceLevel.少冰.rawValue
        case "30%": customDrink.ice = IceLevel.微冰.rawValue
        case "0%": customDrink.ice = IceLevel.去冰.rawValue
        case "常溫": customDrink.ice = IceLevel.常溫.rawValue
        case "溫熱": customDrink.ice = IceLevel.溫熱.rawValue
        default: break
        }
    }
    
    @IBAction func chooseJelly(_ sender: UIButton) {
        if sender == selectedJellyBtn{
            sender.configuration?.baseBackgroundColor = .white
            customDrink.jelly = nil
            jellyPrice = 0
            selectedJellyBtn = nil
        }else{
            for btn in tenDollarJellyButton{
                btn.configuration?.baseBackgroundColor = .white
                btn.isSelected = false
            }
            for btn in fifteenDollarJellyButton{
                btn.configuration?.baseBackgroundColor = .white
                btn.isSelected = false
            }
            
            sender.configuration?.baseBackgroundColor = .yellow
            customDrink.jelly = sender.titleLabel?.text ?? ""
            selectedJellyBtn = sender
            
            switch sender.titleLabel?.text{
            case "鶴頂紅茶凍":
                jellyPrice=10
            case "桂香烏龍凍":
                jellyPrice=10
            default:
                jellyPrice=15
            }
            
        }
        
    }
    
    @IBAction func chooseTopping(_ sender: UIButton) {
        if sender == selectedToppingBtn{
            sender.configuration?.baseBackgroundColor = .white
            toppingPrice = 0
            sender.isSelected = false
            customDrink.topping = nil
        }else{
            for btn in toppingButton{
                btn.configuration?.baseBackgroundColor = .white
                btn.isSelected = false
            }
            sender.configuration?.baseBackgroundColor = .yellow
            sender.isSelected = true
            toppingPrice = 10
            customDrink.topping = sender.titleLabel?.text
            selectedToppingBtn = sender
        }
        
       
        
    }
    
    @IBAction func chooseFavorite(_ sender: UIButton) {
        switch customDrink.name{
        case "鶴記鴛鴦凍奶茶":
            if sender.isSelected{
                sender.configuration?.baseBackgroundColor = .white
                sender.isSelected = false
            }else{
                sender.configuration?.baseBackgroundColor = .yellow
                sender.isSelected = true
                customDrink.favorite = ""
                for btn in optionalButton{
                    if btn.isSelected{
                        if let title = btn.configuration?.title{
                            customDrink.favorite! += "  \(title)"
                        }
                    }
                }
            }
            
        default:
            for btn in optionalButton{
                btn.configuration?.baseBackgroundColor = .white
                btn.isSelected = false
            }
            sender.configuration?.baseBackgroundColor = .yellow
            sender.isSelected = true
            customDrink.favorite = sender.configuration?.title
        }
        
    }
    
    @IBAction func addFreeBlackTeaJelly(_ sender: UISwitch) {
        if sender.isOn{
            customDrink.isAddFreeBlackTeaJelly = "加紅茶凍"
        }else{
            customDrink.isAddFreeBlackTeaJelly = nil
        }
    }
    //將客制好的飲品上傳
    @IBAction func uploadDrink(_ sender: UIButton) {
        //print(customDrink)
        //一般飲品如果沒選大小甜度冰量，就跳出警示訊息
        if customDrink.size == "" || customDrink.sugar == "" || customDrink.ice == ""{
            let alert = UIAlertController(title: "輸入飲品有誤", message: "請確認大小、甜度、冰量", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "確認", style: .default)
            alert.addAction(alertAction)
            present(alert, animated: true)
            return
        }
        //特殊飲品若沒選「愛你所擇」選項，就跳出警示訊息
        if customDrink.name == "鶴記茶凍奶茶" || customDrink.name == "鶴記鴛鴦凍奶茶" || customDrink.name == "鶴記紅茶鮮豆奶"{
            if customDrink.favorite == ""{
                let alert = UIAlertController(title: "輸入飲品有誤", message: "請確認「愛你所擇」選項已選擇", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "確認", style: .default)
                alert.addAction(alertAction)
                present(alert, animated: true)
                return
            }
        }
        
        //儲存選到的飲料到userDefault
        customDrink.number = 1
        costomDrinks.append(Field(fields: customDrink))
        let savedDrinksData = try! JSONEncoder().encode(costomDrinks)
        UserDefaults.standard.set(savedDrinksData, forKey: "savedDrinks")
        //跳出成功選購的訊息
        let alert = UIAlertController(title: "訂購飲料", message: "已成功訂購", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "確認", style: .default){_ in
            self.dismiss(animated: true){
                let number = self.costomDrinks.count
                print("savedDrinksNumber的個數：\(number)")
                self.VC1?.numberOfOrderLabel.text = "\(number)"
            }
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true)
    }
    
    
    
    //用手拉會觸發這個function
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
        
    }
    
    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let customTitle = Custom.allCases
        titleLabel.text = customTitle[section].rawValue
        titleLabel.textColor = UIColor(named: "Color2")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        header.addSubview(titleLabel)
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    //修改免費加紅茶凍的bug
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 6{
            print("奶茶的Cell")
            if milkTeaCell.accessoryType == .none{
                print("打勾勾")
                milkTeaCell.accessoryType = .checkmark
                freeBlackTeaJellySwitch.isEnabled = true
                freeBlackTeaJellySwitch.isOn = true
                customDrink.isAddFreeBlackTeaJelly = "加紅茶凍"
                //鮮奶茶系列是否升級
                if customDrink.size == Size.m.rawValue{
                    milkTeaUpgradePrice = 10
                    customDrink.upgradeMilkTea = "升級燕麥奶"
                }else if customDrink.size == Size.l.rawValue{
                    milkTeaUpgradePrice = 15
                    customDrink.upgradeMilkTea = "升級燕麥奶"
                }
                
            }else{
                print("取消勾勾")
                milkTeaCell.accessoryType = .none
                freeBlackTeaJellySwitch.isOn = false
                freeBlackTeaJellySwitch.isEnabled = false
                customDrink.upgradeMilkTea = nil
                milkTeaUpgradePrice = 0
                customDrink.isAddFreeBlackTeaJelly = nil

            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
