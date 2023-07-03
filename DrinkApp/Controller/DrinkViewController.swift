//
//  ViewController.swift
//  DrinkApp
//
//  Created by JeffApp on 2023/6/7.
//

import UIKit
import Kingfisher
class DrinkViewController: UIViewController {
    var drinksArr:[[Drink]] = []
    var drinksInfo:DrinkBody!
    
    @IBOutlet var categoryButtons: [UIButton]!
    @IBOutlet weak var drinkTableView: UITableView!
    @IBOutlet weak var categoryScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //想改變tarBarItem的位置，但沒有作用
//        tabBarItem.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        drinkTableView.backgroundColor = UIColor(named: "Color1")
        categoryScrollView.showsHorizontalScrollIndicator = false
        changeSelectedBtnAppearance(button: categoryButtons[0])
       
        fetchDrink()
    }

//MARK: - 自定義function
    func fetchDrink(){
        if let url = URL(string: "https://api.airtable.com/v0/applXRGr3hb8H3SoE/DrinkApp"){
            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("Bearer key1rgSyzPr4pBAmu", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: urlRequest) {
                data, response, error
                in
                if let data{
                    let decoder = JSONDecoder()
                    do{
                        self.drinksInfo = try decoder.decode(DrinkBody.self, from: data)
                        self.drinksArr = self.getDrinks()
                        print("drinksArr的個數是：",self.drinksArr.count)
                        DispatchQueue.main.async {
                            self.drinkTableView.reloadData()
                        }
                    }catch{
                        print(error)
                    }
                }
            }.resume()
        }
    }
    
    //沒用到
    func getDrink(drinks:DrinkBody,index:Int)->Drink{
        let drink = drinks.records[index].fields
        return drink
    }

    func getDrinks()->[[Drink]]{
        let records = drinksInfo.records
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
    
    func changeSelectedBtnAppearance(button:UIButton){
        for button in categoryButtons{
            button.configuration?.baseBackgroundColor = UIColor(named: "Color4")
            button.configuration?.baseForegroundColor = UIColor(named: "Color1")
            button.isSelected = false
        }
        
        if button.isSelected == false{
            button.configuration?.baseBackgroundColor = UIColor(named: "Color")
            button.configuration?.baseForegroundColor = UIColor(named: "Color2")
            button.isSelected = true
        }
    }
    
    func moveSelectedCategoryBtn(button:UIButton){
        //setContentOffset的意思是指：以scrollView的原點為基準，位移幾個x
        //按鈕中心點跟scrollView中心點差幾個x
        let xOffset = button.center.x - categoryScrollView.center.x
        //scrollView可以捲的極限在哪，設定的話可以讓最後一個按鈕的tailling貼齊scrollView的tailling
        let xOffsetMax = categoryScrollView.contentSize.width - categoryScrollView.frame.width
        switch xOffset{
        case let x where x > xOffsetMax:
            categoryScrollView.setContentOffset(CGPoint(x: xOffsetMax, y: 0), animated: true)
        case let x where x > 0:
            categoryScrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
        default:
            categoryScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    
    
    func moveCategory(button:UIButton){
        let indexPath = IndexPath(row:0 , section: button.tag)
        drinkTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    
    
    //MARK: - 點擊事件
    @IBAction func selectCategory(_ sender: UIButton) {
        changeSelectedBtnAppearance(button: sender)
        moveCategory(button: sender)
        moveSelectedCategoryBtn(button: sender)
    }
    
    
    @IBSegueAction func showDetail(_ coder: NSCoder) -> DetailViewController? {
        let controller = DetailViewController(coder: coder)
        let indexPath = drinkTableView.indexPathForSelectedRow
        let drink = drinksArr[indexPath!.section][indexPath!.row]
       controller?.drink = drink
        return controller
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        if let controller = storyboard?.instantiateViewController(identifier: "loginViewController"){
            //因為自動登入是判斷token有沒有東西，所以登出後不清掉的話，下次打開app一樣會自動登入
            UserDefaults.standard.removeObject(forKey: "token")
            UserDefaults.standard.removeObject(forKey: "savedDrinks")
            UserDefaults.standard.removeObject(forKey: "savedDrinksNumber")
            view.window?.rootViewController = controller
        }
    }
    
    
}


//MARK: - UITableViewDataSource
extension DrinkViewController:UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let category = Category.allCases
        print("category的個數是：",category.count)
        return category.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let drink = drinks.contains {$0.fields.category[0] == Category.傳統復刻奶茶.rawValue}
        
        //方法一：用switch判斷有drinks有東西時回傳個數
        /*
        switch drinksArr.count{
        case 0:
            return 0
        default:
            return drinksArr[section].count
        }
         */
         
        
        //方法二：如果drinksArr的個數是0成立，就回傳0，否則就回傳drinksArr[section].count的數量
        drinksArr.count == 0 ? 0 : drinksArr[section].count
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkTableViewCell") as! DrinkTableViewCell

        let drink = drinksArr[indexPath.section][indexPath.row]
        //圖片
        var imageUrl:URL
//        if let image = drink.image{
//            imageUrl = image[0].url
//        }else{
//            imageUrl = URL(fileURLWithPath: "")
//        }
        imageUrl = drink.image != nil ? drink.image![0].url : URL(filePath: "")
        cell.drinkImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "default"))
        //飲品名
        cell.drinkNameLabel.text = drink.name
        //價錢
        if let mPrice = drink.M{
            cell.middlePriceLabel.text = "M \(mPrice)"
        }else{
            cell.middlePriceLabel.text = "M --"
        }
        if let lPrince = drink.L{
            cell.largePriceLabel.text = "L \(lPrince)"
        }else{
            cell.largePriceLabel.text = "L --"
        }
        return cell
    }
    //這個方法可以改header內容，但是畫面很窄
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        drinksArr.count != 0 ? drinksArr[section][0].category[0] : ""
//
//    }
    
}
//MARK: - UITableViewDelegate
extension DrinkViewController:UITableViewDelegate{
    //更改section的view與內容
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //新增一個UIView
        let view = UIView()
        view.backgroundColor = UIColor(named: "Color3")
        //新增描述飲料種類的Label
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.frame.width, height: tableView.rowHeight/3))
        //設定飲料種類的文字格式
        let title = drinksArr.count != 0 ? drinksArr[section][0].category[0] : ""
        let font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        let attribute:[NSAttributedString.Key:Any] = [.foregroundColor:UIColor(named: "Color2")!,.font:font]
        let attrubutedText = NSAttributedString(string: title, attributes: attribute)
        //把格式設定進Label
        label.attributedText = attrubutedText
        //View加入Label
        view.addSubview(label)
        //把View變成Section的View
        return view
    }
    //設定Section的高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView.rowHeight/3
    }
    
}
//MARK: - scrollViewDelegate
extension DrinkViewController:UIScrollViewDelegate{
 
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("啟動中")
        let visibleRowsIndexpath = drinkTableView.indexPathsForVisibleRows
        print("visibleRowsIndexpath:\(visibleRowsIndexpath!)")
        let mapSections = visibleRowsIndexpath!.map({$0.section})
        print("mapSections:\(mapSections)")
        print("mapSections.count:\(mapSections.count)")
        print("Set(mapSections).count:\(Set(mapSections).count)")
        if Set(mapSections).count == 1{
            changeSelectedBtnAppearance(button: categoryButtons[mapSections[0]])
            moveSelectedCategoryBtn(button: categoryButtons[mapSections[0]])
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}
