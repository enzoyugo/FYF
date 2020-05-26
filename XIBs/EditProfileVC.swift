//
//  EditProfileVC.swift
//  FYF Beta
//
//  Created by enzo on 4/3/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var referencesTxt: UITextField!
    @IBOutlet weak var houseNumberTxt: UITextField!
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    var selectedUser : User!
    var id = ""
    var email = ""
    var username = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        usernameTxt.text = selectedUser.username
        addressTxt.text = selectedUser.address
        houseNumberTxt.text = selectedUser.houseNumber
        referencesTxt.text = selectedUser.references
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    @IBAction func backBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveChangesBtnWasPressed(_ sender: Any) {
        uploadDocument()
        dismiss(animated: true, completion: nil)
    }
    func uploadDocument(){
        guard let username = usernameTxt.text , username.isNotEmpty,
            let houseNumber = houseNumberTxt.text, houseNumber.isNotEmpty,
            let address = addressTxt.text, address.isNotEmpty,
            let references = referencesTxt.text, references.isNotEmpty
            else  {
                simpleAlert(title: "Campos vacios", msg: "Favor llenar todos los campos")
                return
        }
        self.username = username
        var docRef : DocumentReference!
        let usr = User.init(id: selectedUser.id, email: selectedUser.email, username: username, phoneNumber: selectedUser.phoneNumber, address: address, houseNumber: houseNumber, references: references)
        
        if let collToEdit = selectedUser {
            docRef = Firestore.firestore().collection("users").document(collToEdit.id)
            selectedUser.id = collToEdit.id
        }
        let data = User.modelToData(user: usr)
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
    }
}

