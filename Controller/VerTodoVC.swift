//
//  VerTodoVC.swift
//  FYF Beta
//
//  Created by enzo on 3/27/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class VerTodoVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var verTodoCollview: UICollectionView!
    let db = Firestore.firestore()
    var types : PromoTypes!
    var clothes = [Clothes]()
    var listener : ListenerRegistration!
    var listener1 : ListenerRegistration!
    var priceOrder = Bool()
    var selectedStore: Tiendas!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verTodoCollview?.register(UINib(nibName: "PromosTypeCollViewCell", bundle: nil), forCellWithReuseIdentifier: "PromosTypeCollViewCell")
    }
    let data = DataSet()
    @IBAction func backHomeBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.Types.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PromosTypeCollViewCell", for: indexPath) as? PromosTypeCollViewCell{
            cell.configureCell(types: data.Types[indexPath.item])
            return cell
            
        } else{ return UICollectionViewCell()
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.width - 10), height: 180)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        types = data.Types[indexPath.item]
        performSegue(withIdentifier: "toEachPromo", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEachPromo" {
            if let destination = segue.destination as? EachPromoVC {
                destination.type = types
            }
        }
    }
}
