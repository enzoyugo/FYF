//
//  ColorsVC.swift
//  FYF Beta
//
//  Created by enzo on 3/19/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit

class ColorsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet weak var colorLbl: UILabel!
    var selectedClothes : Clothes!
    let colors = ["Rojo", "Azul", "Floreado"]
    var color = ""
    @IBOutlet weak var pickerColorView: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerColorView.delegate = self
        pickerColorView.dataSource = self
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let vc = ProductDetailVC()
        vc.color = selectedClothes.colors[row]
        color = selectedClothes.colors[row]
        colorLbl.text = selectedClothes.colors[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectedClothes.colors.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectedClothes.colors[row]
    }
    @IBAction func BackBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
