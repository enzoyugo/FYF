//
//  PedidoVC.swift
//  FYF Beta Admin
//
//  Created by enzo on 4/15/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class PedidoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var store : ReservaTienda!
    var reserves = [Reserved]()
    var db = Firestore.firestore()
    var listener : ListenerRegistration!
    @IBOutlet weak var pedidosTblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        pedidosTblView?.register(UINib(nibName: "PedidoCell", bundle: nil), forCellReuseIdentifier: "PedidoCell")
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        setTiendasListener()
    }
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        reserves.removeAll()
        pedidosTblView.reloadData()
    }
    func setTiendasListener() {
        let user = Auth.auth().currentUser
        guard let Uid = user?.uid, Uid.isNotEmpty
            else { simpleAlert(title: "Error", msg: "Cuenta no válida")
                return
        }
        var ref : Query!
        ref = db.collection("Tiendas").document(Uid).collection("reserveStore").document(self.store.userId).collection("cart")
        listener = ref.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let reserves = Reserved.init(data: data)
                
                switch change.type {
                    case.added:
                        self.onDocumentAdded(change: change, category: reserves)
                    case.modified:
                        self.onDocumentModified(change: change, category: reserves)
                    case.removed:
                        self.onDocumentRemoved(change: change)
                }
            })
        })
    }
    func onDocumentAdded(change: DocumentChange, category: Reserved){
        let newIndex = Int(change.newIndex)
        print(category)
        reserves.insert(category, at: newIndex)
        pedidosTblView?.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: UITableView.RowAnimation.left)
        
    }
    func onDocumentModified(change: DocumentChange, category: Reserved){
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            reserves[index] = category
            pedidosTblView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.left)
            
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            reserves.remove(at: oldIndex)
            reserves.insert(category, at: newIndex)
            
            pedidosTblView?.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        reserves.remove(at: Int(oldIndex))
        pedidosTblView?.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: UITableView.RowAnimation.fade)
    }
    @IBAction func backBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reserves.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PedidoCell", for: indexPath) as? PedidoCell{
            let reserve = reserves[indexPath.row]
            cell.configureCell(reserve: reserve)
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
