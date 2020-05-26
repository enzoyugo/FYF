//
//  RegisterVC.swift
//  FYF Beta
//
//  Created by enzo on 3/11/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import SwiftUI
import Firebase
import CoreLocation
import MapKit

class RegisterVC: UIViewController{
    
    @IBOutlet weak var refereciasTxt: UITextField!
    @IBOutlet weak var houseNumberTxt: UITextField!
    @IBOutlet weak var addressTxt: UITextField!
    
    @IBOutlet weak var infoView: RoundedShadowView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var phoneInfo: UIImageView!
    
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var passCheckImg: UIImageView!
    
    @IBOutlet weak var confirmPassCheckImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(infoPressed(_:)))
        tap.numberOfTapsRequired = 1
        phoneInfo.isUserInteractionEnabled = true
        phoneInfo.clipsToBounds = true
        phoneInfo.addGestureRecognizer(tap)
        passwordTxt.addTarget(self , action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        confirmPasswordTxt.addTarget(self , action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        activityIndicator.isHidden = true
        // Do any additional setup after loading the view.
    }
    @IBAction func backInfoBtnPressed(_ sender: Any) {
        infoView.isHidden = true
    }
    @objc func infoPressed(_ tap: UITapGestureRecognizer){
        infoView.isHidden = false
    }
    @objc func textFieldDidChange(_ textField : UITextField){
        guard let passTxt = passwordTxt.text else {return}
        
        
        if textField == confirmPasswordTxt {
            passCheckImg.isHidden = false
            confirmPassCheckImg.isHidden = false
            
        } else {
            if passTxt.isEmpty {
                passCheckImg.isHidden = true
                confirmPassCheckImg.isHidden = true
                confirmPasswordTxt.text = ""
            }
            
        }
        if passwordTxt.text == confirmPasswordTxt.text {
            passCheckImg.image = UIImage(named: AppImages.GreenCheck)
            confirmPassCheckImg.image = UIImage(named: AppImages.GreenCheck)
        } else {
            passCheckImg.image = UIImage(named: AppImages.RedCheck)
            confirmPassCheckImg.image = UIImage(named: AppImages.RedCheck)
        }
        
        
    }
    
    
    @IBAction func registerClicked(_ sender: UIButton) {
        
        guard let email = emailTxt.text , email.isNotEmpty ,
            let username = usernameTxt.text , username.isNotEmpty ,
            let password = passwordTxt.text , password.isNotEmpty,
            let phoneNumber = phoneNumberTxt.text, phoneNumber.isNotEmpty,
            let address = addressTxt.text, address.isNotEmpty,
            let houseNumber = houseNumberTxt.text, houseNumber.isNotEmpty,
            let references = refereciasTxt.text, references.isNotEmpty
            else {
                simpleAlert(title: "Error", msg: "Por favor llenar todos los campos")
                return
        }
        
        guard let confirmPass = confirmPasswordTxt.text , confirmPass == password else {
            simpleAlert(title: "Error", msg: "Las contraseñas no coinciden")
            return
        }
        
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error)
            
            in
            if let error = error {
                Auth.auth().handleFireAuthError(error: error, vc: self)
                self.activityIndicator.stopAnimating()
                return
            }
            guard let firUser = authResult?.user else {return}
            let fyfUser = User.init(id: firUser.uid, email: email, username: username, phoneNumber: phoneNumber, address: address, houseNumber: houseNumber, references: references)
            self.createFirestoreUser(user: fyfUser)
            
        }
    }
    func createFirestoreUser(user: User){
        let newUserRef = Firestore.firestore().collection("users").document(user.id)
        
        let data = User.modelToData(user: user)
        
        newUserRef.setData(data) { (error) in
            if let error = error {
                Auth.auth().handleFireAuthError(error: error, vc: self)
                debugPrint("No se puede subir el documento: \(error.localizedDescription)")
            }else{
                self.activityIndicator.stopAnimating()
                self.dismiss(animated: true, completion: nil)
                
            }
        }
    }
}
