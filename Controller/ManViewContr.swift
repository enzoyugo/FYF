//
//  ManViewContr.swift
//  FYF Beta
//
//  Created by enzo on 3/25/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class ManViewContr: UIViewController {
    
    
    @IBOutlet weak var storesSearchLbl: UITextField!
    @IBOutlet weak var tableViewStores: UITableView!
    
    
    let db = Firestore.firestore()
    var clothes = [Clothes]()
    var tiendas = [Tiendas]()
    var listener : ListenerRegistration!
    var listenerB : ListenerRegistration!
    var selectedStore: Tiendas!
    var allS : AllStores!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableViewStores?.register(UINib(nibName: Identifiers.TiendaCell, bundle: nil), forCellReuseIdentifier: Identifiers.TiendaCell)
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    override func viewDidAppear(_ animated: Bool) {
        setTiendasListener()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        tableViewStores?.reloadData()
    }
    func setTiendasListener() {
        var womanRef : DocumentReference
        womanRef = Firestore.firestore().collection("AllTiendas").document("Hombres")
        womanRef.getDocument { (snap, error) in
            if let error = error{
                debugPrint(error.localizedDescription)
                return
            }
            let data = snap!.data()
            self.allS = AllStores.init(data: data!)
            self.tableViewStores?.reloadData()
        }
    }
    
    @IBAction func storeSearchBtn(_ sender: Any) {
        //        Nada
    }
    
    func onDocumentAdded(change: DocumentChange, category: Tiendas){
        let newIndex = Int(change.newIndex)
        tiendas.insert(category, at: newIndex)
        tableViewStores?.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: UITableView.RowAnimation.left)
        
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
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        tiendas.remove(at: Int(oldIndex))
        tableViewStores?.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: UITableView.RowAnimation.fade)
    }
    
}
extension ManViewContr : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let allS = allS{
            return allS.AllTiendas.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.TiendaCell, for: indexPath) as? TiendasCell {
            let allT = Tiendas.init(data: allS.AllTiendas[indexPath.row])
            cell.configureCell(tiendas: allT)
            return cell
        }
        return UITableViewCell()
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = view.frame.height / 5
        return height
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStore = Tiendas.init(data: allS.AllTiendas[indexPath.row])
        performSegue(withIdentifier: "toTest", sender: self)
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTest" {
            if let destination = segue.destination as? EachStoreTestVC {
                destination.tienda = selectedStore
            }
        }
    }
}
