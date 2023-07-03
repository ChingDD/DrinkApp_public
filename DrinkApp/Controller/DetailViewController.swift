//
//  DetailViewController.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/11.
//

import UIKit
import Kingfisher
class DetailViewController: UIViewController {

    var drink:Drink!
    @IBOutlet weak var drinkImageView: UIImageView!
    
    @IBOutlet weak var recommendationImagwView: UIImageView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var isCaffeineLabel: UILabel!
    
    @IBOutlet weak var recommendationLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var logoImageVIew: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI(drink: drink)
    }
    
    func updateUI(drink:Drink){
        //圖片
        let imageUrl = drink.image != nil ? drink.image![0].url : URL(filePath: "")
        drinkImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "鶴茶樓Logo"))
        //飲品名
        drinkNameLabel.text = drink.name
        drinkNameLabel.sizeToFit()
        drinkNameLabel.layer.borderColor = UIColor(named: "Color1")?.cgColor
        //咖啡因
        isCaffeineLabel.layer.cornerRadius = 10
        if drink.noCaffeine == "false"{
            isCaffeineLabel.text = "有咖啡因"
        }else{
            isCaffeineLabel.text = "無咖啡因"
        }
        
        //信心喝法
        recommendationLabel.layer.cornerRadius = 10
        recommendationLabel.text = "信心喝法：\(drink.recommendSugar)，\(drink.recommendIce)"
        
        //描述
        switch drink.description{
        case nil:
            descriptionLabel.isHidden = true
            logoImageVIew.isHidden = false
        default:
            descriptionLabel.isHidden = false
            descriptionLabel.text = drink.description
            logoImageVIew.isHidden = true
        }
        //信心推薦
        switch drink.confidence == "true"{
        case true:
            recommendationImagwView.image = UIImage(named: "推薦")
        default:
            recommendationImagwView.isHidden = true
        }
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
