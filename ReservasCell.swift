//
//  ReservasCell.swift
//  FYF Beta Admin
//
//  Created by enzo on 4/4/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit

class ReservasCell: UITableViewCell {
    
    
    
    @IBOutlet weak var referencesLbl: UILabel!
    @IBOutlet weak var houseNumberLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    
    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(reserves : ReservaTienda){
        addressLbl.text = reserves.address
        houseNumberLbl.text = reserves.houseNumber
        referencesLbl.text = reserves.references
        nameLbl.text = reserves.name
        usernameLbl.text = reserves.username
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date(timeIntervalSince1970: TimeInterval(reserves.timeStamp.seconds))
        let myString = formatter.string(from: date) // string purpose I add here
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "dd-MMM-yyyy HH:mm"
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)
        dateLbl.text = myStringafd
    }
    
}
