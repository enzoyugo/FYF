//
//  AdminProductsVC.swift
//  FYF Beta Admin
//
//  Created by enzo on 3/21/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit

class AdminProductsVC: EachStoreTestVC {
    
    var selectedProduct : Clothes?
    var selectedType : TypesOfCLothing?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction override func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func editStoreBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: Segues.toEditStore, sender: self)
    }
    
    @IBAction func newProductBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: Segues.toAddEditProduct, sender: self)
    }
    
    @IBAction func newFilterBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: Segues.toAddEditFilter, sender: self)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.ClothesCollView {
            let clothesSt = Clothes.init(data: tienda.Clothess[indexPath.item])
            selectedProduct = clothesSt
            performSegue(withIdentifier: Segues.toAddEditProduct, sender: self)
        } else if collectionView == self.PickerCollView{
            selectedType = typesOfClothing[indexPath.item]
            performSegue(withIdentifier: Segues.toAddEditFilter, sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toAddEditProduct {
            if let destination = segue.destination as? AddEditProductsVC {
                destination.selectedCategory = tienda
                destination.productToEdit = selectedProduct
            }
        } else if segue.identifier == Segues.toEditStore{
            if let destination = segue.destination as? AddEditCategoryVC {
                destination.storeToEdit = tienda
                
            }
        } else if segue.identifier == Segues.toAddEditFilter {
            if let destination = segue.destination as? AddEditFiltersVC {
                destination.selectedStore = tienda
                destination.filterToEdit = selectedType
            }
        }
    }
}
