//
//  MessagesVC.swift
//  FYF Beta
//
//  Created by enzo on 4/12/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class MessagesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var emptyCartView: UIView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var messagesTblView: UITableView!
    var stores = [ReservaTienda]()
    var ref : Query!
    var user = User()
    let db = Firestore.firestore()
    var userListener : ListenerRegistration!
    var listener : ListenerRegistration!
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesTblView?.register(UINib(nibName: "allCartsTblViewCell", bundle: nil), forCellReuseIdentifier: "allCartsTblViewCell")
        
    }
    
    @IBAction func keepLookingBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "toPromos", sender: self)
    }
    override func viewDidAppear(_ animated: Bool) {
        emptyCartView.isHidden = true
        getStores()
        messagesTblView?.reloadData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        stores.removeAll()
        messagesTblView?.reloadData()
    }
    func getStores(){
        
        ref = Firestore.firestore().collection("users").document(UserService.user.id).collection("reserveStore")
        listener = ref.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let store = ReservaTienda.init(data: data)
                
                switch change.type {
                    case.added:
                        self.onDocumentAdded(change: change, category: store)
                    case.modified:
                        self.onDocumentModified(change: change, category: store)
                    case.removed:
                        self.onDocumentRemoved(change: change)
                }
            })
            
        })
    }
    func onDocumentAdded(change: DocumentChange, category: ReservaTienda){
        let newIndex = Int(change.newIndex)
        stores.insert(category, at: newIndex)
        messagesTblView?.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: UITableView.RowAnimation.left)
        
    }
    func onDocumentModified(change: DocumentChange, category: ReservaTienda){
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            stores[index] = category
            messagesTblView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.left)
            
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            stores.remove(at: oldIndex)
            stores.insert(category, at: newIndex)
            
            messagesTblView?.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        stores.remove(at: Int(oldIndex))
        messagesTblView?.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: UITableView.RowAnimation.fade)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if stores.count == 0{
            emptyCartView.isHidden = false
        } else if stores.count >= 1{
            emptyCartView.isHidden = true
        }
        return stores.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "allCartsTblViewCell", for: indexPath) as? allCartsTblViewCell{
            cell.configureCell(store: stores[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CartVC()
        vc.store = stores[indexPath.row]
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
        messagesTblView?.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 129
    }
}
