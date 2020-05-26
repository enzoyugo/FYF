//
//  CartTblViewCell.swift
//  FYF Beta
//
//  Created by enzo on 4/14/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Kingfisher

class CartTblViewCell: UITableViewCell {
    
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var colorLbl: UILabel!
    @IBOutlet weak var sizeLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var clothesImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(reserve : Reserved){
        colorLbl.text = reserve.color
        sizeLbl.text = reserve.size
        nameLbl.text = reserve.name
        if let url = URL(string: reserve.imgUrl) {
            clothesImg.kf.setImage(with: url)
        }
        let attributeStringB : NSMutableAttributedString = NSMutableAttributedString(string: "Gs.\((Int(reserve.price)).formattedWithSeparator)")
        priceLbl.attributedText = attributeStringB
    }
    
}
