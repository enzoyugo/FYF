//
//  LoginVC.swift
//  FYF Beta
//
//  Created by enzo on 3/11/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func forgotPassClicked(_ sender: Any) {
        let vc = ForgotPassVC()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
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
            let storyboard = UIStoryboard(name: "HomeNC" , bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: Storyboard.FirstHomeVC)
            
            self?.present(controller, animated: true, completion: nil)
        }
    }
}
