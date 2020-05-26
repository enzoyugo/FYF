//
//  AddToCollectionVC.swift
//  FYF Beta
//
//  Created by enzo on 3/31/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class AddToCollectionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var AddBtn: RoundedButton!
    var listener : ListenerRegistration!
    var selectedProduct : Clothes!
    var selectedColl : Collections!
    @IBOutlet weak var collTblView: UITableView!
    var coll = [Collections]()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        AddBtn.isEnabled = false
        collTblView?.register(UINib(nibName: "addCollectionsTblViewCell", bundle: nil), forCellReuseIdentifier: "addCollectionsTblViewCell")
        collTblView?.delegate = self
        collTblView?.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getCollData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        coll.removeAll()
        collTblView.reloadData()
    }
    
    func getCollData(){
        let ref = Firestore.firestore().collection("users").document(UserService.user.id).collection("collections")
        listener = ref.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let coll = Collections.init(data: data)
                
                switch change.type {
                    case.added:
                        self.onDocumentAdded(change: change, category: coll)
                    case.modified:
                        self.onDocumentModified(change: change, category: coll)
                    case.removed:
                        self.onDocumentRemoved(change: change)
                    
                }
            })
            
        })
        coll.removeAll()
        collTblView?.reloadData()
    }
    
    func onDocumentAdded(change: DocumentChange, category: Collections){
        let newIndex = Int(change.newIndex)
        coll.insert(category, at: newIndex)
        collTblView?.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: UITableView.RowAnimation.automatic)
        
    }
    func onDocumentModified(change: DocumentChange, category: Collections){
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            coll[index] = category
            collTblView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.automatic)
            
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            coll.remove(at: oldIndex)
            coll.insert(category, at: newIndex)
            
            collTblView?.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
            
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        coll.remove(at: Int(oldIndex))
        collTblView?.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: UITableView.RowAnimation.automatic)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coll.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "addCollectionsTblViewCell", for: indexPath) as? addCollectionsTblViewCell {
            cell.configureCell(coll: coll[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedColl = coll[indexPath.row]
        AddBtn.isEnabled = true
        return
    }
    @IBAction func newCollectionBtnPressed(_ sender: Any) {
        let vc = NewCollVC()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addBtnPressed(_ sender: Any) {
        let likesRef = Firestore.firestore().collection("users").document(UserService.user.id).collection("collections").document(selectedColl.id).collection("clothes")
        if UserService.savedCl.contains(selectedProduct){
            // remove
            UserService.savedCl.removeAll{ $0 == selectedProduct }
            likesRef.document(selectedColl.id).delete()
        } else {
            //add
            UserService.savedCl.append(selectedProduct)
            let data = Clothes.modelToData(clothes: selectedProduct)
            likesRef.document(selectedProduct.id).setData(data)
        }
        Firestore.firestore().collection("Clothes").document(selectedProduct.id).setData(["likes" : selectedProduct.likes + 1], merge: true)
        dismiss(animated: true, completion: nil)
    }
}

