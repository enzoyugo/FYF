//
//  tagsCell.swift
//  FYF Beta Admin
//
//  Created by enzo on 3/21/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit

class tagsCell: UITableViewCell {
    var Tags = [String]()
    @IBOutlet weak var tagTxt: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
