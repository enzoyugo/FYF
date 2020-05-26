//
//  LoginVCAdmin.swift
//  FYF Beta Admin
//
//  Created by enzo on 4/4/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class LoginVCAdmin: UIViewController {
    
    @IBOutlet weak var logInBtn: RoundedButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        if let _ = Auth.auth().currentUser {
            performSegue(withIdentifier: "toHome", sender: self)
            
        }
    }
    @IBAction func LoginClicked(_ sender: Any) {
        guard let email = emailTxt.text , email.isNotEmpty ,
            let password = passwordTxt.text , password.isNotEmpty
            else {
                simpleAlert(title: "Error", msg: "Por favor llenar todos los campos")
                return
                
        }
        activityIndicator.startAnimating()
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                Auth.auth().handleFireAuthError(error: error, vc: self!)
                self?.activityIndicator.stopAnimating()
                return
            }
            self?.activityIndicator.stopAnimating()
            self?.performSegue(withIdentifier: "toHome", sender: self)
        }
    }
}
