//
//  ForgotPassVC.swift
//  FYF Beta
//
//  Created by enzo on 3/12/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase
class ForgotPassVC: UIViewController {
    
    @IBOutlet weak var emailForgotPass: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPassBtnPressed(_ sender: Any) {
        guard let email = emailForgotPass.text, email.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Ingrese un email válido")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                debugPrint(error)
                Auth.auth().handleFireAuthError(error: error, vc: self)
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
