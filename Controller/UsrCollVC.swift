//
//  UsrCollVC.swift
//  FYF Beta
//
//  Created by enzo on 4/2/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class UsrCollVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    @IBOutlet weak var btnsStackView: UIStackView!
    @IBOutlet weak var editCollBtn: UIButton!
    @IBOutlet weak var readyBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var deleteCollBtn: UIButton!
    @IBOutlet weak var clothesCollView: UICollectionView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var collTitle: UILabel!
    @IBOutlet weak var collImage: UIImageView!
    var selectedColl : Collections!
    var db : Firestore!
    var listener: ListenerRegistration!
    var clothes = [Clothes]()
    var deleteBtnBool : Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: selectedColl.image) {
            collImage?.kf.setImage(with: url)
        }
        descLbl?.text = selectedColl.description
        collTitle?.text = selectedColl.title
        clothesCollView?.register(UINib(nibName: Identifiers.ClothingTypeCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.ClothingTypeCell)
        db = Firestore.firestore()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        getClothesData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        clothes.removeAll()
        clothesCollView?.reloadData()
    }
    @IBAction func deleteCollBtnWasPressed(_ sender: Any) {
        let likesRef = Firestore.firestore().collection("users").document(UserService.user.id).collection("collections")
        if UserService.likes.contains(selectedColl){
            // remove
            UserService.likes.removeAll{ $0 == selectedColl }
            likesRef.document(selectedColl.id).delete()
        } else {return}
        dismiss(animated: true, completion: nil)
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func editCollBtnPressed(_ sender: Any) {
        let vc = NewCollVC()
        vc.collToEdit = selectedColl
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    @IBAction func editBtn(_ sender: Any) {
        editBtn.isHidden = true
        readyBtn.isHidden = false
        btnsStackView.isHidden = false
        deleteBtnBool = false
        clothesCollView?.reloadData()
    }
    @IBAction func readyBtnWasPressed(_ sender: Any) {
        editBtn.isHidden = false
        deleteBtnBool = true
        readyBtn.isHidden = true
        btnsStackView.isHidden = true
        clothesCollView?.reloadData()
    }
    func getClothesData(){
        let ref = db.collection("users").document(UserService.user.id).collection("collections")
        
        let reff = ref.document(selectedColl.id).collection("clothes").order(by: "timeStamp", descending: true)
        listener =  reff.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let clothes = Clothes.init(data: data)
                
                switch change.type {
                    case.added:
                        self.onDocumentAdded(change: change, category: clothes)
                    case.modified:
                        self.onDocumentModified(change: change, category: clothes)
                    case.removed:
                        self.onDocumentRemoved(change: change)
                    
                }
            })
            
        })
        clothes.removeAll()
        clothesCollView?.reloadData()
    }
    
    func onDocumentAdded(change: DocumentChange, category: Clothes){
        let newIndex = Int(change.newIndex)
        clothes.insert(category, at: newIndex)
        clothesCollView?.insertItems(at: [IndexPath(item: newIndex, section: 0)])
        
    }
    func onDocumentModified(change: DocumentChange, category: Clothes){
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            clothes[index] = category
            clothesCollView?.reloadItems(at: [IndexPath(item: index, section: 0)])
            
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            clothes.remove(at: oldIndex)
            clothes.insert(category, at: newIndex)
            
            clothesCollView?.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        clothes.remove(at: Int(oldIndex))
        clothesCollView?.deleteItems(at: [IndexPath(row: oldIndex, section: 0)])
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clothes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.ClothingTypeCell, for: indexPath) as? RowColectionView{
            cell.configureCell(clothes: clothes[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width / 2) - (22 * 2), height: view.frame.height / 3)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if deleteBtnBool == true {
            let vc = ProductDetailVC()
            let selectedClothes = clothes[indexPath.item]
            vc.clothes = selectedClothes
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
        } else {
            let likesRef = Firestore.firestore().collection("users").document(UserService.user.id).collection("collections").document(selectedColl.id).collection("clothes")
            if UserService.savedCl.contains(clothes[indexPath.row]){
                // remove
                UserService.savedCl.removeAll{ $0 == clothes[indexPath.row] }
                likesRef.document(clothes[indexPath.row].id).delete()
            } else {
                //add
                UserService.savedCl.append(clothes[indexPath.row])
                let data = Clothes.modelToData(clothes: clothes[indexPath.row])
                likesRef.document(clothes[indexPath.row].id).setData(data)
            }
        }
    }
}
