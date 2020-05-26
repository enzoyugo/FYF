//
//  ReservasVC.swift
//  FYF Beta Admin
//
//  Created by enzo on 4/4/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class ReservasVC: UIViewController {
    var listener: ListenerRegistration!
    var db = Firestore.firestore()
    @IBOutlet weak var reservasTblView: UITableView!
    @IBOutlet weak var reservasLbl: UILabel!
    let user = Auth.auth().currentUser
    var tiendas = [Tiendas]()
    var clothes = [Clothes]()
    var reserve = [ReservaTienda]()
    var store : ReservaTienda!
    override func viewDidLoad() {
        super.viewDidLoad()
        reservasTblView.register(UINib(nibName: "ReservasCell", bundle: nil), forCellReuseIdentifier: "ReservasCell")
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        setTiendasListener()
    }
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        reserve.removeAll()
        reservasTblView?.reloadData()
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func setTiendasListener() {
        guard let Uid = user?.uid, Uid.isNotEmpty
            else { simpleAlert(title: "Error", msg: "Cuenta no válida")
                return
        }
        var ref : Query!
        ref = db.collection("Tiendas").document(Uid).collection("reserveStore").order(by: "timeStamp", descending: true)
        listener = ref.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let reserve = ReservaTienda.init(data: data)
                
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
    func onDocumentAdded(change: DocumentChange, category: ReservaTienda){
        let newIndex = Int(change.newIndex)
        print(category)
        reserve.insert(category, at: newIndex)
        reservasTblView?.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: UITableView.RowAnimation.left)
        
    }
    func onDocumentModified(change: DocumentChange, category: ReservaTienda){
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            reserve[index] = category
            reservasTblView?.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.left)
            
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            reserve.remove(at: oldIndex)
            reserve.insert(category, at: newIndex)
            
            reservasTblView?.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        reserve.remove(at: Int(oldIndex))
        reservasTblView?.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: UITableView.RowAnimation.fade)
    }
}
extension ReservasVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reserve.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ReservasCell", for: indexPath) as? ReservasCell {
            cell.configureCell(reserves: reserve[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        func openWhatsapp(){
            let urlWhats = "whatsapp://send?phone=\(reserve[indexPath.row].phoneNumber)."
            if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
                if let whatsappURL = URL(string: urlString) {
                    if UIApplication.shared.canOpenURL(whatsappURL){
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(whatsappURL)
                        }
                    }
                    else {
                        print("Install Whatsapp")
                    }
                }
            }
        }
        
        let refreshAlert = UIAlertController(title: "Fin de pedido", message: "El pedido fue completado? (las acciones no se pueden deshacer)", preferredStyle: UIAlertController.Style.alert)
        refreshAlert.addAction(UIAlertAction(title: "Ver productos", style: .default, handler: { (action: UIAlertAction!) in
            self.store = self.reserve[indexPath.row]
            self.performSegue(withIdentifier: "toPedidoVC", sender: self)
            refreshAlert.dismiss(animated: true, completion: nil)
        }))
        refreshAlert.addAction(UIAlertAction(title: "Confirmar pedido", style: .default, handler: { (action: UIAlertAction!) in
            openWhatsapp()
            refreshAlert.dismiss(animated: true, completion: nil)
        }))
        refreshAlert.addAction(UIAlertAction(title: "Entregado", style: .default, handler: { (action: UIAlertAction!) in
            guard let Uid = self.user?.uid, Uid.isNotEmpty
                else { self.simpleAlert(title: "Error", msg: "Cuenta no válida")
                    return
            }
            let likesRef = Firestore.firestore().collection("Tiendas").document(Uid).collection("reserveStore")
            
            likesRef.document(self.reserve[indexPath.row].userId).delete()
            
            refreshAlert.dismiss(animated: true, completion: nil)
        }))
        
        
        refreshAlert.addAction(UIAlertAction(title: "Pedido cancelado", style: .default, handler: { (action: UIAlertAction!) in
            let likesRef = Firestore.firestore().collection("Tiendas").document(self.user!.uid).collection("reserveStore")
            Firestore.firestore().collection("Clothes").document(self.reserve[indexPath.row].id).setData(["LessStock" : -1], merge: true)
            likesRef.document(self.reserve[indexPath.row].id).delete()
            refreshAlert.dismiss(animated: true, completion: nil)
        }))
        refreshAlert.addAction(UIAlertAction(title: "cerrar", style: .cancel, handler: { (action: UIAlertAction!) in
            refreshAlert.dismiss(animated: true, completion: nil)
        }))
        present(refreshAlert, animated: true, completion: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPedidoVC" {
            if let destination = segue.destination as? PedidoVC {
                destination.store = self.store
            }
        }
    }
}
