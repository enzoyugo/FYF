//
//  NewCollVC.swift
//  FYF Beta
//
//  Created by enzo on 4/1/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class NewCollVC: UIViewController {
    
    @IBOutlet weak var addCollBtn: RoundedButton!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var descriptionColl: UITextField!
    @IBOutlet weak var imageColl: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var titles = ""
    var collToEdit : Collections!
    var descriptions = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:)))
        tap.numberOfTapsRequired = 1
        imageColl.isUserInteractionEnabled = true
        imageColl.clipsToBounds = true
        imageColl.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
        if let coll = collToEdit {
            nameTxt.text = coll.title
            descriptionColl.text = coll.description
            addCollBtn.setTitle("Guardar cambios", for: .normal)
            if let url = URL(string: coll.image){
                imageColl.contentMode = .scaleAspectFill
                imageColl.kf.setImage(with: url)
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    @objc func imgTapped(_ tap: UITapGestureRecognizer){
        launchImgPicker()
    }
    @IBAction func agregarCollBtn(_ sender: Any) {
        uploadImageThenDoc()
    }
    @IBAction func atrasBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func uploadImageThenDoc() {
        guard let image = imageColl.image,
            let titles = nameTxt.text , titles.isNotEmpty,
            let description = descriptionColl.text, description.isNotEmpty
            else {
                simpleAlert(title: "Campos vacios", msg: "Favor llenar todos los campos")
                return
        }
        self.titles = titles
        self.descriptions = description
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {return}
        
        let imageRef = Storage.storage().reference().child("/collImages/\(titles).jpg")
        
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
        var coll = Collections.init(title: titles , image: url , description: descriptions , id: "")
        
        if let collToEdit = collToEdit {
            docRef = Firestore.firestore().collection("users").document(UserService.user.id).collection("collections").document(collToEdit.id)
            coll.id = collToEdit.id
        } else {
            docRef = Firestore.firestore().collection("users").document(UserService.user.id).collection("collections").document()
            coll.id = docRef.documentID
        }
        let data = Collections.modelToData(coll: coll)
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

extension NewCollVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func launchImgPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        imageColl.contentMode = .scaleAspectFill
        imageColl.image = image
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
