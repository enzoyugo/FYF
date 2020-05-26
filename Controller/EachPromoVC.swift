//
//  EachPromoVC.swift
//  FYF Beta
//
//  Created by enzo on 4/15/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class EachPromoVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    var type : PromoTypes!
    var clothes = [Clothes]()
    var allCl : FilterClothes!
    var listener : ListenerRegistration!
    let db = Firestore.firestore()
    @IBOutlet weak var promosCollView: UICollectionView!
    @IBOutlet weak var promosLbl: UILabel!
    @IBOutlet weak var promoImg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        promosLbl.text = type.displayName
        promoImg.image = UIImage(named: type.imgName)
        promosCollView?.register(UINib(nibName: Identifiers.ClothingTypeCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.ClothingTypeCell)
        // Do any additional setup after loading the view.
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        getRowData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        clothes.removeAll()
        promosCollView?.reloadData()
    }
    func getRowData(){
        listener = db.collection("TypesOfClothing").document(type.displayName).addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            let data = snap!.data()
            if data != nil{
                let allCl = FilterClothes.init(data: data!)
                self.allCl = allCl
                self.promosCollView?.reloadData()
            }
        })
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let allCl = allCl{
            return allCl.Clothes.count
        }
        else {
            return 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.ClothingTypeCell, for: indexPath) as?  RowColectionView{
            let clothes = Clothes.init(data: allCl.Clothes[indexPath.item])
            cell.configureCell(clothes: clothes)
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (Int(self.view.frame.size.width / 2) - 20), height: 200)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ProductDetailVC()
        let clothes = Clothes.init(data: allCl.Clothes[indexPath.item])
        vc.clothes = clothes
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
}
