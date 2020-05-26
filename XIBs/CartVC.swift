//
//  CartVC.swift
//  FYF Beta
//
//  Created by enzo on 4/14/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class CartVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var store : ReservaTienda!
    @IBOutlet weak var storeLbl: UILabel!
    @IBOutlet weak var cartTblView: UITableView!
    var ref : Query!
    var db = Firestore.firestore()
    var listener : ListenerRegistration!
    var listenerB : ListenerRegistration!
    var reserve = [Reserved]()
    override func viewDidLoad() {
        super.viewDidLoad()
        storeLbl.text = "Carrito \(store.name)"
        cartTblView?.register(UINib(nibName: "CartTblViewCell", bundle: nil), forCellReuseIdentifier: "CartTblViewCell")
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        getStores()
    }
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        reserve.removeAll()
        cartTblView?.reloadData()
    }
    func getStores(){
        
        ref = Firestore.firestore().collection("users").document(UserService.user.id).collection("reserveStore").document(store.id).collection("cart")
        listener = ref.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let reserve = Reserved.init(data: data)
                
                switch change.type {
                    case.added:
                        self.onDocumentAdded(change: change, category: reserve)
                    case.modified:
                        self.onDocumentModified(change: change, category: reserve)
                    case.removed:
                        self.onDocumentRemoved(change: change)
                }
            })
            
        })
    }
    func onDocumentAdded(change: DocumentChange, category: Reserved){
        let newIndex = Int(change.newIndex)
        reserve.insert(category, at: newIndex)
        cartTblView?.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: UITableView.RowAnimation.left)
        
    }
    func onDocumentModified(change: DocumentChange, category: Reserved){
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            reserve[index] = category
            cartTblView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.left)
            
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            reserve.remove(at: oldIndex)
            reserve.insert(category, at: newIndex)
            
            cartTblView?.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        reserve.remove(at: Int(oldIndex))
        cartTblView?.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: UITableView.RowAnimation.fade)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reserve.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CartTblViewCell", for: indexPath) as? CartTblViewCell{
            cell.configureCell(reserve: reserve[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deleteAlert = UIAlertController(title: "Borrar", message: "Desea sacar la prenda de su carrito?", preferredStyle: UIAlertController.Style.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Sacar", style: .default, handler: { (action: UIAlertAction!) in
            let cartRef = Firestore.firestore().collection("users").document(UserService.user.id).collection("reserveStore").document(self.store.id).collection("cart")
            if self.reserve.count == 1 {
                if self.reserve.contains(self.reserve[indexPath.row]){
                    // remove
                    cartRef.document(self.reserve[indexPath.row].id).delete()
                }
                let likesRef = Firestore.firestore().collection("users").document(UserService.user.id).collection("reserveStore")
                likesRef.document(self.store.id).delete()
                self.dismiss(animated: true, completion: nil)
                deleteAlert.dismiss(animated: true, completion: nil)
            } else {
                if self.reserve.contains(self.reserve[indexPath.row]){
                    // remove
                    cartRef.document(self.reserve[indexPath.row].id).delete()
                    tableView.reloadData()
                    deleteAlert.dismiss(animated: true, completion: nil)
                }
            }
            
        }))
        deleteAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
            deleteAlert.dismiss(animated: true, completion: nil)
        }))
        present(deleteAlert, animated: true, completion: nil)
    }
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func pedidoBtn(_ sender: Any) {
        let reserveAlert = UIAlertController(title: "Confirmar pedido", message: "Desea hacer el pedido?", preferredStyle: UIAlertController.Style.alert)
        
        reserveAlert.addAction(UIAlertAction(title: "Proceder", style: .default, handler: { (action: UIAlertAction!) in
            var docRef : DocumentReference
            var storeRef : DocumentReference
            storeRef = Firestore.firestore().collection("Tiendas").document(self.store.id).collection("reserveStore").document(UserService.user.id)
            let data1 = ReservaTienda.modelToData(reservaTienda: self.store)
            storeRef.setData(data1, merge: true) { (error) in
                if let error = error {
                    self.handleError(error: error, msg: "No se puede subir el documento")
                    return
                }
            }
            self.listener.remove()
            for reserve in 0...self.reserve.count - 1{
                print(reserve)
                var reserved = reserve - reserve
                Firestore.firestore().collection("Clothes").document(self.reserve[reserved].clothesId).setData(["LessStock" : 1], merge: true)
                docRef = Firestore.firestore().collection("Tiendas").document(self.store.id).collection("reserveStore").document(UserService.user.id).collection("cart").document(self.reserve[reserved].id)
                let data = Reserved.modelToData(reserve: self.reserve[reserved])
                docRef.setData(data, merge: true) { (error) in
                    if let error = error {
                        self.handleError(error: error, msg: "No se puede subir el documento")
                        return print("ua")
                    }
                }
                let likesRef = Firestore.firestore().collection("users").document(UserService.user.id).collection("reserveStore").document(self.store.id).collection("cart")
                if
                    self.reserve.contains(self.reserve[reserved]){
                    // remove
                    likesRef.document(self.reserve[reserved].id).delete()
                    self.reserve.removeAll{ $0 == self.reserve[reserved] }
                } else {
                    self.simpleAlert(title: "error", msg: "eso")
                }
            }
            let likesRef = Firestore.firestore().collection("users").document(UserService.user.id).collection("reserveStore")
            likesRef.document(self.store.id).delete()
            self.dismiss(animated: true, completion: nil)
            let vc = MessagesVC()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }))
        reserveAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
            reserveAlert.dismiss(animated: true, completion: nil)
        }))
        present(reserveAlert, animated: true, completion: nil)
    }
    func handleError(error : Error, msg : String){
        debugPrint(error.localizedDescription)
        simpleAlert(title: "Error", msg: msg)
    }
}
