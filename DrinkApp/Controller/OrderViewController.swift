//
//  OrderViewController.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/12.
//

import UIKit
import Kingfisher

class OrderViewController: UIViewController {
    var drinks:[[Drink]]!
    var savedOrdersNumber = "0"
    @IBOutlet var categoryButtons: [UIButton]!
    @IBOutlet weak var orderCollectionView: UICollectionView!
    @IBOutlet weak var categoryScrollView: UIScrollView!
    @IBOutlet weak var numberOfOrderLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("畫面viewDidLoad")
        //預設button最一開始的樣子
        changeSelectedBtnAppearance(button: categoryButtons[0])
        //設定collectionView格式
        configLayout()
        //抓取資料
        DrinkController.shared.fetchDrinks(collectionView: orderCollectionView, from: "https://api.airtable.com/v0/applXRGr3hb8H3SoE/DrinkApp") {
            result
            in
            switch result{
            case .success(let drinks):
                self.drinks = drinks
            case .failure(let error):
                print(error)
            }
        }
        //註冊一個空HeaderView
        orderCollectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("畫面viewWillAppear")
        
        if let savedCustomDrinksData = UserDefaults.standard.data(forKey: "savedDrinks"){
            let savedCustomDrinks = try! JSONDecoder().decode([Field].self, from: savedCustomDrinksData)
            self.numberOfOrderLabel.text = "\(savedCustomDrinks.count)"
        }
        
    }
    

    
    //MARK: - 自定義function
    //collectionView裡的Flow Layout決定cell怎麼排列以及header的顯示
    func configLayout(){
        categoryScrollView.showsHorizontalScrollIndicator = false

        let cellSpacing = 10.0
        let itemLineSpacing = 10.0
        let cellCount = 2.0
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        //cell的size
        let width = floor((categoryScrollView.frame.width-(cellCount-1+2)*cellSpacing)/cellCount)
        print("Width:\(width)")
        layout.itemSize = CGSize(width: width, height: width)
        layout.estimatedItemSize = .zero
        //間距設定
        layout.minimumLineSpacing = itemLineSpacing
        layout.minimumInteritemSpacing = cellSpacing
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        // 設定Section Header高度（沒設的話class裡的設定都會出不來）
        layout.headerReferenceSize = CGSize(width: 0, height: 50)
        orderCollectionView.collectionViewLayout = layout
    }
    
    
    
    func changeSelectedBtnAppearance(button:UIButton){
        for btn in categoryButtons{
            btn.configuration?.baseBackgroundColor = UIColor(named: "Color4")
            btn.configuration?.baseForegroundColor = UIColor(named: "Color1")
            btn.isSelected = false
        }
        
        switch button.isSelected{
        case false:
            button.configuration?.baseBackgroundColor = UIColor(named: "Color")
            button.configuration?.baseForegroundColor = UIColor(named: "Color2")
        default:
            break
        }
    }
    
    
    func moveCategory(button:UIButton){
        //let indexPath = IndexPath(item: drinks[button.tag].count-1, section: button.tag)
        let indexPath = IndexPath(item: 1, section: button.tag)
        orderCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            //找出來的point位置怪怪的
//            let point = headerViews[button.tag].convert(CGPoint.zero, to: orderCollectionView)
//            orderCollectionView.setContentOffset(point, animated: true)
//            print(point)
    }
    
    func moveSelectedBtn(button:UIButton){
        let xOffset = button.center.x - categoryScrollView.center.x
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
    
    func getSectionHeight(count:Int)->Int{
        //因為每一列有2個飲料，所以可以算出組共有幾列
        let rows = count/2
        //看有無餘數
        let remainder = count%2
        var itemHeight:Int!
        var sectionHeight:Int!
        var rowInset:Int!
        //若剛好整除，則rows的數量就不用+1
        if remainder == 0{
            itemHeight = rows*181
            rowInset = (rows-1)*10
            sectionHeight = 50+10+rowInset+itemHeight+10
        }else{
            //若有除數，則rows的數量就會+1
            itemHeight = (rows+1)*181
            rowInset = (rows)*10
            sectionHeight = 50+10+rowInset+itemHeight+10
        }
        return sectionHeight
    }
    
   
    //MARK: - Target Action
    @IBAction func selectCategory(_ sender: UIButton) {
        changeSelectedBtnAppearance(button: sender)
        moveCategory(button: sender)
        moveSelectedBtn(button: sender)
    }
    
    @IBSegueAction func showCustomPage(_ coder: NSCoder) -> CustomTableViewController? {
        let controller = CustomTableViewController(coder: coder)
        let indexPath = orderCollectionView.indexPathsForSelectedItems?.first
        let selectedDrink = drinks[indexPath!.section][indexPath!.item]
        controller?.drink = selectedDrink
        controller?.VC1 = self
        return controller
    }
    
    @IBAction func unwindToOrderPage(_ unwindSegue: UIStoryboardSegue) {
        print("跑unwindSegue")
        let payVC = unwindSegue.source as! PayTableViewController
        print("改變前savedOrdersNumber：\(savedOrdersNumber)")
        print("payVC.savedOrdersNumber：\(payVC.savedOrdersNumber)")
        self.savedOrdersNumber = payVC.savedOrdersNumber
        print("改變後savedOrdersNumber：\(savedOrdersNumber)")
        numberOfOrderLabel.text = savedOrdersNumber
    }
   
    @IBAction func logOut(_ sender: UIButton) {
        //沒有轉型的原因是因為我沒有要用到它裡面的元件，只是單純秀出畫面而已
        if let controller = storyboard?.instantiateViewController(identifier: "loginViewController"){
            UserDefaults.standard.removeObject(forKey: "token")
            UserDefaults.standard.removeObject(forKey: "savedDrinks")
            UserDefaults.standard.removeObject(forKey: "savedDrinksNumber")
            view.window?.rootViewController = controller
        }
    }
    
    
    
}
//MARK: - UICollectionViewDataSource
extension OrderViewController:UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Category.allCases.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        drinks != nil ? drinks[section].count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderCollectionViewCell", for: indexPath) as! OrderCollectionViewCell
        let drink = drinks[indexPath.section][indexPath.item]
        //飲料圖片
        let imageUrl = drink.image != nil ? drink.image![0].url : URL(string: "")
        cell.imageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "鶴茶樓Logo"))
        //飲料名字
        cell.nameLabel.text = drink.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let category = Category.allCases[indexPath.section].rawValue
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
        headerView.label.text = category
        return headerView
    }
    
    
    
    
}


//MARK: - UIScrollViewDelegate
extension OrderViewController:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffset = orderCollectionView.contentOffset
        print("contentOffset:\(contentOffset)")
        var sectionHeights:[CGFloat]=[]
        var yOffSet:[CGFloat]=[]
        //y最多可移動的距離(不設定的話最後一個section的位置會跑掉)
        let scrollMax:CGFloat = orderCollectionView.contentSize.height-orderCollectionView.frame.height
        //儲存移動一個section的y軸距離
        for i in 0...4{
            let drinkCounts = drinks[i].count
            sectionHeights.append(CGFloat(getSectionHeight(count: drinkCounts)))
            if i == 0{
                yOffSet.append(CGFloat(getSectionHeight(count: drinkCounts)))
            }else{
                yOffSet.append(yOffSet[i-1]+sectionHeights[i])
            }
        }
        print("scrollMax:\(scrollMax)")
        print("sectionHeights:\(sectionHeights)")
        print("yOffSet:\(yOffSet)")
        //判斷當位移的距離是特定數字時，要切換按鈕顏色及移動按鈕的位置
        switch contentOffset.y{
        //當位移的距離是0
        case let x where x < yOffSet[0]:
            //將第一個按鈕變色
            changeSelectedBtnAppearance(button: categoryButtons[0])
            moveSelectedBtn(button: categoryButtons[0])
        //若位移的距離是可滾動的最大值
        case let x where x >= scrollMax:
            //將最後一顆按鈕變色
            changeSelectedBtnAppearance(button: categoryButtons[5])
            //移動最後一顆按鈕到scrollView的中間
            moveSelectedBtn(button: categoryButtons[5])
        //當移動第四個section的距離
        case let x where x > yOffSet[3]:
            //第五顆按鈕樣式與位置要改變
            changeSelectedBtnAppearance(button: categoryButtons[4])
            moveSelectedBtn(button: categoryButtons[4])
        //當移動第三個section的距離
        case let x where x > yOffSet[2]:
            //第四顆按鈕樣式與位置要改變
            changeSelectedBtnAppearance(button: categoryButtons[3])
            moveSelectedBtn(button: categoryButtons[3])
        //當移動第二個section的距離
        case let x where x > yOffSet[1]:
            //第三顆按鈕樣式與位置要改變
            changeSelectedBtnAppearance(button: categoryButtons[2])
            moveSelectedBtn(button: categoryButtons[2])
        //當移動第一個section的距離
        case let x where x > yOffSet[0]:
            //第二顆按鈕樣式與位置要改變
            changeSelectedBtnAppearance(button: categoryButtons[1])
            moveSelectedBtn(button: categoryButtons[1])
        default:
            break
        }
    }
   
    
    
}
//MARK: - UICollectionViewDelegateFlowLayout
extension OrderViewController:UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//    }

}
