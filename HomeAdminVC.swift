//
//  ViewController.swift
//  FYF Beta Admin
//
//  Created by enzo on 3/8/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class ViewController: HomeNCVC {
    let user = Auth.auth().currentUser
    @IBOutlet weak var newStoreBtn: RoundedButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(view.frame.width)
    }
    override func viewDidAppear(_ animated: Bool) {
        setTiendasListener()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        self.tiendas.removeAll()
        self.tableViewStores?.reloadData()
    }
    @IBAction func newStoreBtnPressed(_ sender: Any) {
        let vc = NewStorePassword()
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    @IBAction func logOutBtnPressed(_ sender: Any) {
        if let _ = Auth.auth().currentUser {
            do{
                try Auth.auth().signOut()
            } catch {
                Auth.auth().handleFireAuthError(error: error, vc: self)
            }
        } else { performSegue(withIdentifier: "toLogin", sender: self)
        }
    }
    override func setTiendasListener() {
        guard let Uid = user?.uid, Uid.isNotEmpty
            else { simpleAlert(title: "Error", msg: "Cuenta no válida")
                return
        }
        var ref : Query!
        ref = db.collection("Tiendas").whereField("id", isEqualTo: Uid)
        listener = ref.addSnapshotListener({ (snap, error) in
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
            self.tableViewStores?.reloadData()
        })
    }
    func onDocumentAdded(change: DocumentChange, category: Tiendas){
        let newIndex = Int(change.newIndex)
        tiendas.insert(category, at: newIndex)
        tableViewStores?.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: UITableView.RowAnimation.none)
        
    }
    func onDocumentModified(change: DocumentChange, category: Tiendas){
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            tiendas[index] = category
            tableViewStores?.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.left)
            
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            tiendas.remove(at: oldIndex)
            tiendas.insert(category, at: newIndex)
            
            tableViewStores?.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }
    override func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        tiendas.remove(at: Int(oldIndex))
        tableViewStores?.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: UITableView.RowAnimation.fade)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tiendas.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.TiendaCell, for: indexPath) as? TiendasCell{
            cell.configureCell(tiendas: tiendas[indexPath.row])
        }
        return UITableViewCell()
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tienda = tiendas[indexPath.row]
        selectedStore = tienda
        performSegue(withIdentifier: "toTest", sender: self)
    }
}

