//
//  AddEditCategoryVC.swift
//  FYF Beta Admin
//
//  Created by enzo on 3/19/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class AddEditCategoryVC: UIViewController {
    
    @IBOutlet weak var womanSwitch: UISwitch!
    @IBOutlet weak var manSwitch: UISwitch!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var tiendasImg: RoundedImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addBtn: RoundedButton!
    var clothes : Clothes?
    var tiendasClothes : [[String : Any]]?
    var types : TypesOfCLothing?
    var storeToEdit : Tiendas?
    var tienda : Tiendas!
    var all : AllStores!
    let user = Auth.auth().currentUser
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:)))
        tap.numberOfTapsRequired = 1
        tiendasImg?.isUserInteractionEnabled = true
        tiendasImg?.addGestureRecognizer(tap)
        
        if let category = storeToEdit {
            self.tienda = category
            self.tiendasClothes = category.Clothess
            womanSwitch.isOn = category.mujer
            manSwitch.isOn = category.hombre
            nameTxt.text = category.name
            addBtn.setTitle("Guardar cambios", for: .normal)
            if let url = URL(string: category.imgUrl) {
                tiendasImg?.contentMode = .scaleAspectFill
                tiendasImg?.kf.setImage(with: url)
            }
        }
        
    }
    
    @IBAction func mujerBtnisOn(_ sender: Any) {
        var womanRef : DocumentReference
        womanRef = Firestore.firestore().collection("AllTiendas").document("Mujeres")
        womanRef.getDocument { (snap, error) in
            if let error = error{
                debugPrint(error.localizedDescription)
                return
            }
            let data = snap!.data()
            self.all = AllStores.init(data: data!)
            
        }
    }
    @IBAction func hombreBtnisOn(_ sender: Any) {
        var manRef : DocumentReference
        manRef = Firestore.firestore().collection("AllTiendas").document("Hombres")
        manRef.getDocument { (snap, error) in
            if let error = error{
                debugPrint(error.localizedDescription)
                return
            }
            let data = snap!.data()
            self.all = AllStores.init(data: data!)
            
        }
    }
    @objc func imgTapped(_ tap: UITapGestureRecognizer){
        launchImgPicker()
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func addStoreClicked(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Subir", message: "Subir los documentos", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Agregar", style: .default, handler: { (action: UIAlertAction!) in
            self.uploadImageThenDoc()
            refreshAlert.dismiss(animated: true, completion: nil)
        }))
        refreshAlert.addAction(UIAlertAction(title: "Finalizar", style: .default, handler: { (action: UIAlertAction!) in
            if self.womanSwitch.isOn == true{
                var womanRef : DocumentReference!
                let tienda = Tiendas.modelToData(tienda: self.tienda)
                self.all.AllTiendas.append(tienda)
                let allTheStores = AllStores.modelToData(tiendas: self.all)
                womanRef = Firestore.firestore().collection("AllTiendas").document("Mujeres")
                womanRef.setData(allTheStores)
            } else if self.manSwitch.isOn == true{
                var manRef : DocumentReference!
                let tienda = Tiendas.modelToData(tienda: self.tienda)
                self.all.AllTiendas.append(tienda)
                let allTheStores = AllStores.modelToData(tiendas: self.all)
                manRef = Firestore.firestore().collection("AllTiendas").document("Hombres")
                manRef.setData(allTheStores)
            }
            self.activityIndicator.stopAnimating()
            self.dismiss(animated: true, completion: nil)
            
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    func uploadImageThenDoc(){
        
        guard let image = tiendasImg.image , let tiendasName = nameTxt.text , tiendasName.isNotEmpty else {
            simpleAlert(title: "Error", msg: "Datos Incompletos")
            return
        }
        activityIndicator.startAnimating()
        guard let imageData = image.jpegData(compressionQuality: 0.2) else {return}
        
        let imageRef = Storage.storage().reference().child("/TiendasImages/\(tiendasName).jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        imageRef.putData(imageData, metadata: metaData) { (metaData, error) in
            
            if let error = error{
                self.handleError(error: error, msg: "No se puede Subir la imagen")
            }
            imageRef.downloadURL { (url, error) in
                if let error = error{
                    self.handleError(error: error, msg: "No se puede sacar el Url")                           }
                
                guard let url = url else {return}
                
                self.uploadDoc(url: url.absoluteString)
            }
        }
    }
    func uploadDoc(url: String){
        guard let Uid = user?.uid, Uid.isNotEmpty
            else { simpleAlert(title: "Error", msg: "Cuenta no válida")
                return
        }
        var docRef : DocumentReference!
        self.tienda = Tiendas.init(name: nameTxt.text!,
                                   id: "",
                                   imgUrl: url,
                                   timeStamp: Timestamp(),
                                   hombre: manSwitch.isOn,
                                   mujer: womanSwitch.isOn, Clothess:
            self.tiendasClothes ??
                [Clothes.modelToData(clothes: clothes ?? Clothes.init(data: ["1" : "a"]))])
        
        if let categoryToEdit = storeToEdit {
            docRef = Firestore.firestore().collection("Tiendas").document(categoryToEdit.id)
            self.tienda.id = categoryToEdit.id
        } else {
            docRef = Firestore.firestore().collection("Tiendas").document(user!.uid)
            self.tienda.id = Uid
        }
        let data = Tiendas.modelToData(tienda: self.tienda)
        docRef.setData(data, merge: true) { (error) in
            if let error = error{
                self.handleError(error: error, msg: "No se puede Subir la nueva Tienda a Firestore")
                return
            }
            self.activityIndicator.stopAnimating()
        }
        
    }
    func handleError(error: Error, msg: String){
        
        debugPrint(error.localizedDescription)
        self.simpleAlert(title: "Error", msg: msg)
        self.activityIndicator.stopAnimating()
        return
    }
}

extension AddEditCategoryVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func launchImgPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {return}
        tiendasImg.contentMode = .scaleAspectFill
        tiendasImg.image =  image
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
