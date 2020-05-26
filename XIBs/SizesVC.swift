//
//  SizesVC.swift
//  FYF Beta
//
//  Created by enzo on 3/19/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit

class SizesVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let sizes = ["xs", "s", "m", "l", "xl"]
    var selectedClothes : Clothes!
    @IBOutlet weak var pickerClothesView: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerClothesView.delegate = self
        pickerClothesView.dataSource = self
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectedClothes.sizes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectedClothes.sizes[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let vc = ProductDetailVC()
        vc.size = selectedClothes.sizes[row]
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
