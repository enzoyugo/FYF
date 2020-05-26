//
//  PedidoCell.swift
//  FYF Beta Admin
//
//  Created by enzo on 4/15/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit

class PedidoCell: UITableViewCell {
    
    @IBOutlet weak var dateLbl: UILabel!
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
        sizeLbl.text = "Tamaño: \(reserve.size)"
        nameLbl.text = reserve.name
        let attributeStringB : NSMutableAttributedString = NSMutableAttributedString(string: "Gs.\((Int(reserve.price)).formattedWithSeparator)")
        priceLbl.attributedText = attributeStringB
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date(timeIntervalSince1970: TimeInterval(reserve.time.seconds))
        let myString = formatter.string(from: date) // string purpose I add here
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "dd-MMM-yyyy HH:mm"
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)
        dateLbl.text = myStringafd
        
        if let url = URL(string: reserve.imgUrl) {
            clothesImg.kf.setImage(with: url)
        }
    }
}
