//
//  DogsVC.swift
//  FYF Beta
//
//  Created by enzo on 3/15/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class DogsVC: UIViewController {
    
    @IBOutlet weak var dogsTblView: UITableView!
    var dogsClothes = [DogsClothes]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let clothing = DogsClothes.init(name: "munch", id: "dknlrkv", imgUrl: "https://marpet.com.py/assets/img/logo.png", isActive: true, timeStamp: Timestamp())
        dogsClothes.append(clothing)
        dogsTblView?.delegate = self
        dogsTblView?.dataSource = self
        dogsTblView?.register(UINib(nibName: "DogsTableViewCell", bundle: nil), forCellReuseIdentifier: "DogsTableViewCell")
        
        
    }
    
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
extension DogsVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dogsClothes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DogsTableViewCell", for: indexPath) as? DogsTableViewCell{
            cell.configureCell(dogCl: dogsClothes[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = view.frame.height / 5
        return height
    }
    
}
