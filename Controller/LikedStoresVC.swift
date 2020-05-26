//
//  LikedStoresVC.swift
//  FYF Beta
//
//  Created by enzo on 5/2/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class LikedStoresVC: UIViewController {
    
    @IBOutlet weak var clothesTblView: UITableView!
    let db = Firestore.firestore()
    var listener : ListenerRegistration!
    var tiendas = [Tiendas]()
    override func viewDidLoad() {
        super.viewDidLoad()
        clothesTblView?.register(UINib(nibName: Identifiers.TiendaCell, bundle: nil), forCellReuseIdentifier: Identifiers.TiendaCell)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        storeListeners()
    }
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        tiendas.removeAll()
        clothesTblView?.reloadData()
    }
    func storeListeners(){
        listener = db.collection("users").document(UserService.user.id).collection("likedStores").addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let tienda = Tiendas.init(data: data)
                
                switch change.type {
                    case.added:
                        self.onDocumentAdded(change: change, category: tienda)
                    case.modified:
                        self.onDocumentModified(change: change, category: tienda)
                    case.removed:
                        self.onDocumentRemoved(change: change)
                    
                }
            })
            
        })
        tiendas.removeAll()
        clothesTblView?.reloadData()
    }
    func onDocumentAdded(change: DocumentChange, category: Tiendas){
        let newIndex = Int(change.newIndex)
        tiendas.insert(category, at: newIndex)
        clothesTblView?.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: UITableView.RowAnimation.none)
        
    }
    func onDocumentModified(change: DocumentChange, category: Tiendas){
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            tiendas[index] = category
            clothesTblView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.left)
            
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            tiendas.remove(at: oldIndex)
            tiendas.insert(category, at: newIndex)
            
            clothesTblView?.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        tiendas.remove(at: Int(oldIndex))
        clothesTblView?.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: UITableView.RowAnimation.fade)
    }
    func handleError(error : Error, msg : String){
        debugPrint(error.localizedDescription)
        self.simpleAlert(title: "Error", msg: msg)
    }
    
    
}
extension LikedStoresVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tiendas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.TiendaCell, for: indexPath) as? TiendasCell {
            cell.configureCell(tiendas: tiendas[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = view.frame.height / 5
        return height
    }
    
}
