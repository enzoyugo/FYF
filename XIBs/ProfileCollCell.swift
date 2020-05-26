//
//  ProfileCollCell.swift
//  FYF Beta
//
//  Created by enzo on 4/2/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileCollCell: UICollectionViewCell {
    
    @IBOutlet weak var collName: UILabel!
    @IBOutlet weak var CollImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(coll : Collections){
        collName.text = coll.title
        
        if let url = URL(string: coll.image) {
            CollImg.kf.setImage(with: url)
        }
        
        
    }
    
    
}
