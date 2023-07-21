//
//  PaymentTableViewCell.swift
//  DrinkApp
//
//  Created by 林仲景 on 2023/6/23.
//

import UIKit

class PaymentTableViewCell: UITableViewCell {
    @IBOutlet weak var drinkName: UILabel!
    @IBOutlet weak var customLabel: UILabel!
    @IBOutlet weak var favoriteFlavorLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var orderNumber: UILabel!
    @IBOutlet weak var orderNumberStepper: UIStepper!
    @IBOutlet weak var drinkAmountsStepper: UIStepper!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
