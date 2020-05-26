//
//  NewPhotosVC.swift
//  FYF Beta
//
//  Created by enzo on 4/6/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
class NewPhotosVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var newPhImgView: UIImageView!
    @IBOutlet weak var addBtn: RoundedButton!
    @IBOutlet weak var colorPickerView: UIPickerView!
    @IBOutlet weak var descTxt: RoundedTxtView!
    var clothes : Clothes!
    var user = User()
    var username : String!
    var color : String?
    var colors = ""
    let db = Firestore.firestore()
    var listener : ListenerRegistration!
    var userListener : ListenerRegistration!
    var desc = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:)))
        tap.numberOfTapsRequired = 1
        newPhImgView.isUserInteractionEnabled = true
        newPhImgView.clipsToBounds = true
        newPhImgView.addGestureRecognizer(tap)
        colorPickerView.delegate = self
        colorPickerView.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        getCurrentAUser()
    }
    override func viewDidDisappear(_ animated: Bool) {
        userListener.remove()
        user = User()
    }
    func getCurrentAUser() {
        guard let authUser = Auth.auth().currentUser else { return }
        
        let userRef = Firestore.firestore().collection("users").document(authUser.uid)
        userListener = userRef.addSnapshotListener({ (snap, error) in
            if let error = error{
                debugPrint(error.localizedDescription)
                return
            }
            guard let data = snap?.data() else { return }
            self.user = User.init(data: data)
            self.username = self.user.username
        })
    }
    @objc func imgTapped(_ tap: UITapGestureRecognizer){
        launchImgPicker()
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return clothes.colors.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return clothes.colors[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        color = clothes.colors[row]
    }
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addBtn(_ sender: Any) {
        uploadImageThenDoc()
    }
    func uploadImageThenDoc() {
        guard let image = newPhImgView.image,
            let color = color , color.isNotEmpty,
            let description = descTxt.text, description.isNotEmpty
            else {
                simpleAlert(title: "Campos vacios", msg: "Favor llenar todos los campos")
                return
        }
        self.desc = description
        self.colors = color
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {return}
        
        let imageRef = Storage.storage().reference().child("/clothesImages/\(clothes.name)\(username ?? "")\(Int.random(in: 1..<150000)).jpg")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            if let error = error {
                self.handleError(error: error, msg: "La imagen no se pudo subir")
                return
            }
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    self.handleError(error: error, msg: "No se puede descargar el url")
                    return
                }
                guard let url = url else {return}
                
                self.uploadDocument(url: url.absoluteString)
                
                
            }
            
        }
    }
    func uploadDocument(url: String){
        var docRef : DocumentReference!
        var photo = Photos.init(username: username, imgUrl: url, description: desc, id: "", clothesId: clothes.id, color: colors, onOff: false)
        docRef = Firestore.firestore().collection("ClothesPhotos").document()
        photo.id = docRef.documentID
        let data = Photos.modelToData(photo: photo)
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                self.handleError(error: error, msg: "No se puede subir el documento")
                return
            }
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func handleError(error : Error, msg : String){
        debugPrint(error.localizedDescription)
        simpleAlert(title: "Error", msg: msg)
        activityIndicator.stopAnimating()
    }
    
}
extension NewPhotosVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func launchImgPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        newPhImgView.contentMode = .scaleAspectFill
        newPhImgView.image = image
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
