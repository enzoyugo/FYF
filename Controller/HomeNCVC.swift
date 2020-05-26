//
//  HomeNCVC.swift
//  FYF Beta
//
//  Created by enzo on 3/12/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase


class HomeNCVC: UIViewController, UITabBarDelegate {
    
    @IBOutlet weak var storesSearchLbl: UITextField!
    @IBOutlet weak var tableViewStores: UITableView!
    
    let db = Firestore.firestore()
    var clothes = [Clothes]()
    var tiendas = [Tiendas]()
    var allTiendas = [AllStores]()
    var listener : ListenerRegistration!
    var listenerB : ListenerRegistration!
    var selectedStore: Tiendas!
    var all : AllStores!
    var showLikes = false
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewStores?.register(UINib(nibName: Identifiers.TiendaCell, bundle: nil), forCellReuseIdentifier: Identifiers.TiendaCell)
    }
    override func viewDidAppear(_ animated: Bool) {
        setTiendasListener()
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    func setTiendasListener() {
        var womanRef : DocumentReference
        womanRef = Firestore.firestore().collection("AllTiendas").document("Mujeres")
        womanRef.getDocument { (snap, error) in
            if let error = error{
                debugPrint(error.localizedDescription)
                return
            }
            let data = snap!.data()
            self.all = AllStores.init(data: data!)
            self.tableViewStores?.reloadData()
        }
    }
    @IBAction func storeSearchBtn(_ sender: Any) {
// nada
    }
    
    func onDocumentAdded(change: DocumentChange, category: AllStores){
        let newIndex = Int(change.newIndex)
        allTiendas.insert(category, at: newIndex)
    }
    func onDocumentModified(change: DocumentChange, category: AllStores){
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            allTiendas[index] = category
            
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            allTiendas.remove(at: oldIndex)
            allTiendas.insert(category, at: newIndex)
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        allTiendas.remove(at: Int(oldIndex))
        //        tableViewStores?.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: UITableView.RowAnimation.fade)
    }
    func handleError(error : Error, msg : String){
        debugPrint(error.localizedDescription)
        self.simpleAlert(title: "Error", msg: msg)
    }
    
}
extension HomeNCVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(allTiendas.count)
        if let all = all{
            return all.AllTiendas.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.TiendaCell, for: indexPath) as? TiendasCell {
            let allStores = all.AllTiendas
            let tienda = Tiendas.init(data: allStores[indexPath.row])
            cell.configureCell(tiendas: tienda)
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = view.frame.height / 5
        return height
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let allStores = all.AllTiendas
        let tienda = Tiendas.init(data: allStores[indexPath.row])
        selectedStore = tienda
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
