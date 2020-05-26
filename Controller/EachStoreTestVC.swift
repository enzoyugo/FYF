//
//  EachStoreTestVC.swift
//  FYF Beta
//
//  Created by enzo on 3/18/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class EachStoreTestVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    var typesOfClothing = [TypesOfCLothing]()
    var clothes = [Clothes]()
    var tienda: Tiendas!
    var tiendas = [Tiendas]()
    var db : Firestore!
    
    @IBOutlet weak var likeBtn: UIButton!
    
    @IBOutlet weak var eachStoreLogo: UIImageView!
    @IBOutlet weak var PickerCollView: UICollectionView!
    @IBOutlet weak var ClothesCollView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ClothesCollView.register(UINib(nibName: "RowColectionView", bundle: nil), forCellWithReuseIdentifier: "RowColectionView")
        if UserService.likedStores.contains(tienda) {
            likeBtn?.setImage(Image.init(systemName: "heart.fill"), for: UIControl.State.normal)
            self.view.layoutIfNeeded()
        } else {
            likeBtn?.setImage(Image.init(systemName: "heart"), for: UIControl.State.normal)
        }
        if let url = URL(string: tienda.imgUrl) {
            eachStoreLogo?.kf.setImage(with: url)
        }
        db = Firestore.firestore()
        self.view.addSubview(ClothesCollView)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        getRowData()
        ClothesCollView.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        tienda.Clothess.removeAll()
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func likeBtnWasPressed(_ sender: Any) {
        let likesRef = Firestore.firestore().collection("users").document(UserService.user.id).collection("likedStores")
        if UserService.likedStores.contains(tienda){
            // remove
            UserService.likedStores.removeAll{ $0 == tienda }
            likesRef.document(tienda.id).delete()
        } else {
            //add
            UserService.likedStores.append(tienda)
            let data = Tiendas.modelToData(tienda: tienda)
            likesRef.document(tienda.id).setData(data)
        }
        if UserService.likedStores.contains(tienda) {
            likeBtn.setImage(Image.init(systemName: "heart.fill"), for: UIControl.State.normal)
            self.view.layoutIfNeeded()
        } else {
            likeBtn.setImage(Image.init(systemName: "heart"), for: UIControl.State.normal)
        }
    }
    func getRowData(){
        db.collection("Tiendas").whereField("id", isEqualTo: tienda.id).getDocuments { (snap, error) in
            if let error = error{
                debugPrint(error.localizedDescription)
            } else {
                for document in snap!.documents{
                    let data = document.data()
                    let store = Tiendas.init(data: data)
                    self.tienda = store
                }
                self.ClothesCollView?.reloadData()
            }
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tienda.Clothess.count
    }
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.ClothingTypeCell, for: indexPath) as? RowColectionView  {
            let cloth = tienda.Clothess[indexPath.item]
            let clothes = Clothes.init(data: cloth)
            cell.configureCell(clothes: clothes)
            return cell
        } else {
            return UICollectionViewCell()
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width / 2) - (22 * 2), height: view.frame.height / 3)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let clothess = Clothes.init(data: tienda.Clothess[indexPath.item])
        let vc = ProductDetailVC()
        let selectedClothes = clothess
        vc.clothes = selectedClothes
        vc.selectedStore = tienda
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
}
