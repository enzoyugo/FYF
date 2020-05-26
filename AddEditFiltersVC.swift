//
//  AddEditFiltersVC.swift
//  FYF Beta Admin
//
//  Created by enzo on 3/21/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class AddEditFiltersVC: UIViewController {
    
    @IBOutlet weak var addFilterBtn: RoundedButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var typesTxt: UITextField!
    var selectedStore : Tiendas!
    var filterToEdit : TypesOfCLothing?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let filter = filterToEdit {
            typesTxt.text = filter.title
            addFilterBtn.setTitle("Guardar cambios", for: .normal)
        }
        
    }
    
    @IBAction func backBtnpressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func addFilterBtnPressed(_ sender: Any) {
        uploadDocument()
        self.activityIndicator.startAnimating()
    }
    func uploadDocument(){
        guard let title = typesTxt.text , title.isNotEmpty
            else {
                simpleAlert(title: "Campos vacios", msg: "Favor llenar todos los campos")
                return
        }
        var docRef : DocumentReference!
        var typesOfClothing = TypesOfCLothing.init(title: title, id: "", tienda: selectedStore.id)
        if let filterToEdit = filterToEdit {
            docRef = Firestore.firestore().collection("TypesOfCLothing").document(filterToEdit.id)
            typesOfClothing.id = filterToEdit.id
        } else {
            docRef = Firestore.firestore().collection("TypesOfCLothing").document()
            typesOfClothing.id = docRef.documentID
            
        }
        let data = TypesOfCLothing.modelToData(types: typesOfClothing)
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                self.handleError(error: error, msg: "No se puede subir el documento")
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func handleError(error : Error, msg : String){
        debugPrint(error.localizedDescription)
        simpleAlert(title: "Error", msg: msg)
        activityIndicator.stopAnimating()
    }
}
