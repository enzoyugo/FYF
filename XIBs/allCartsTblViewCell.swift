//
//  allCartsTblViewCell.swift
//  FYF Beta
//
//  Created by enzo on 4/14/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Kingfisher

class allCartsTblViewCell: UITableViewCell {
    
    @IBOutlet weak var logoImgVew: RoundedImageView!
    @IBOutlet weak var verCarritoLbl: UILabel!
    @IBOutlet weak var storeNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(store : ReservaTienda){
        storeNameLbl.text = store.name
        if let url = URL(string: store.storeLogo) {
            logoImgVew?.kf.setImage(with: url)
        }
    }
    
}
