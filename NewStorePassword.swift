//
//  NewStorePassword.swift
//  FYF Beta Admin
//
//  Created by enzo on 4/4/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class NewStorePassword: UIViewController {
    
    @IBOutlet weak var passwordTxt: UITextField!
    var db = Firestore.firestore()
    var Pass : String!
    var listener : ListenerRegistration!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        getPasswrd()
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ingresarBtnPressed(_ sender: Any) {
        if passwordTxt.text == Pass {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(identifier: "AddEditCategoryVC")
            present(controller, animated: true, completion: nil)
        } else {
            simpleAlert(title: "Error", msg: "Contraseña incorrecta")
        }
    }
    func getPasswrd(){
        let docRef = db.collection("NewStorePass").document("cwbfCi8Rj4kQrcAfyi44")
        listener = docRef.addSnapshotListener { (snap, error) in
            guard let data = snap?.data() else { return }
            let passwrd = data["password"] as! String
            self.Pass = passwrd
        }
        
    }
}
