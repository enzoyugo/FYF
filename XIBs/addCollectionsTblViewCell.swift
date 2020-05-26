//
//  addCollectionsTblViewCell.swift
//  FYF Beta
//
//  Created by enzo on 3/31/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class addCollectionsTblViewCell: UITableViewCell {
    
    @IBOutlet weak var collLbl: UILabel!
    @IBOutlet weak var collImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func configureCell(coll : Collections){
        collLbl.text = coll.title
        if let url = URL(string: coll.image) {
            collImage.kf.setImage(with: url)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
