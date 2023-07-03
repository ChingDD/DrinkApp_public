//
//  HeaderView.swift
//  DrinkApp
//
//  Created by JeffApp on 2023/6/13.
//

import UIKit

class HeaderView: UICollectionReusableView {
    let label: UILabel = {
       let label = UILabel()
       label.translatesAutoresizingMaskIntoConstraints = false
       label.font = .systemFont(ofSize: 25, weight: UIFont.Weight.semibold)
        label.textColor = UIColor(named: "Color2")
       label.textAlignment = .center
       label.backgroundColor = UIColor(named: "Color4")
       return label
       }()
    override init(frame: CGRect) {
           super.init(frame: frame)

           //backgroundColor = UIColor(named: "Color2")
           addSubview(label)
           NSLayoutConstraint.activate(
            [
               label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
               label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
               label.topAnchor.constraint(equalTo: topAnchor, constant: 0),
               label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
           ]
           )
       }
    
       
   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
}
