//
//  ProductDetailVC.swift
//  FYF Beta
//
//  Created by enzo on 3/18/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ProductDetailVC: UIViewController {
    
    @IBOutlet weak var colorsLbl: UILabel!
    @IBOutlet weak var sizesLbl: UILabel!
    @IBOutlet weak var sizesPickerView: UIPickerView!
    @IBOutlet weak var colorsPickerView: UIPickerView!
    @IBOutlet var sizesVC: UIView!
    @IBOutlet var colorsVC: UIView!
    @IBOutlet weak var reservarBtn: RoundedButton!
    @IBOutlet weak var newPriceLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var clothesImg: UIImageView!
    
    @IBOutlet weak var clothesName: UILabel!
    @IBOutlet weak var clothesPrice: UILabel!
    var reservarBtnEnabled : Bool = true
    var username = ""
    var user = User()
    var phoneNumber = ""
    var userListener : ListenerRegistration!
    var dateClicked : TimeInterval = 1000000000000
    var db : Firestore!
    var listener: ListenerRegistration!
    var likesListener : ListenerRegistration!
    var clothes : Clothes!
    var selectedStore : Tiendas!
    var reserve : Reserved!
    var size = ""
    var color = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:)))
        tap.numberOfTapsRequired = 1
        clothesImg.isUserInteractionEnabled = true
        clothesImg.clipsToBounds = true
        clothesImg.addGestureRecognizer(tap)
        if clothes.price >= clothes.oldPrice {
            clothesPrice.text = "Gs.\((Int(clothes.price)).formattedWithSeparator)"
            clothesPrice.textColor = .white
            newPriceLbl.isHidden = true
        } else {
            let attributeString : NSMutableAttributedString = NSMutableAttributedString(string: "Gs.\((Int(clothes.oldPrice)).formattedWithSeparator)")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            
            clothesPrice.attributedText = attributeString
            clothesPrice.textColor = .red
            newPriceLbl.text = "Gs.\((Int(clothes.price)).formattedWithSeparator)"
            newPriceLbl.isHidden = false
        }
        //        likesLbl.text = "\(Int(self.clothes.likes)) likes"
        clothesName.text = clothes.name
        if let url = URL(string: clothes.imgClUrl){
            clothesImg.kf.setImage(with: url)
        }
    }
    @objc func imgTapped(_ tap: UITapGestureRecognizer){
        let refreshAlert = UIAlertController(title: "Prendas", message: "Desea ver más fotos o añadir una nueva", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ver", style: .default, handler: { (action: UIAlertAction!) in
            let vc = MasFotosVC()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.clothes = self.clothes
            self.present(vc, animated: true, completion: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Añadir", style: .default, handler: { (action: UIAlertAction!) in
            let vc = NewPhotosVC()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.clothes = self.clothes
            self.present(vc, animated: true, completion: nil)
        }))
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
            refreshAlert.dismiss(animated: true, completion: nil)
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        //        getLikesCount()
        getCurrentAUser()
        stock()
    }
    override func viewDidDisappear(_ animated: Bool) {
        //        likesListener.remove()
        userListener?.remove()
        
    }
    func stock(){
        if clothes.LessStock > 0{
            Firestore.firestore().collection("Clothes").document(self.clothes.id).setData(["stock" : clothes.stock - clothes.LessStock], merge: true)
            Firestore.firestore().collection("Clothes").document(self.clothes.id).setData(["LessStock" : 0], merge: true)
        } else { return }
    }
    @IBAction func colorClicked(_ sender: Any) {
        colorsVC.isHidden = false
        
    }
    @IBAction func colorsBack(_ sender: Any) {
        colorsVC.isHidden = true
    }
    @IBAction func tamanosClicked(_ sender: Any) {
        sizesVC.isHidden = false
    }
    @IBAction func sizesBack(_ sender: Any) {
        sizesVC.isHidden = true
        print(size)
    }
    @IBAction func likeClicked(_ sender: Any) {
        let vc = AddToCollectionVC()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
        vc.selectedProduct = self.clothes
    }
    @IBAction func reservarClicked(_ sender: Any) {
        if clothes.stock > 0{
            let reserveAlert = UIAlertController(title: "Carrito", message: "Seguro que desea añadir al carrito?", preferredStyle: UIAlertController.Style.alert)
            
            reserveAlert.addAction(UIAlertAction(title: "Añadir", style: .default, handler: { (action: UIAlertAction!) in
                self.dateClicked = Date.timeIntervalSinceReferenceDate
                let timer = Timestamp.init()
                var docRef : DocumentReference!
                var reserves = Reserved.init(username: UserService.user.username, time: timer, id: "", imgUrl: self.clothes.imgClUrl, name: self.clothes.name, price: self.clothes.price, size: self.size, color: self.color, clothesId: self.clothes.id, phoneNumber: UserService.user.phoneNumber)
                let store = ReservaTienda.init(name: self.clothes.storeName, id: self.clothes.tienda, username: UserService.user.username, timeStamp: Timestamp(), userId: UserService.user.id, phoneNumber: UserService.user.phoneNumber, address: UserService.user.address, houseNumber: UserService.user.houseNumber, references: UserService.user.references, storeLogo: self.clothes.storeLogo)
                var storeRef : DocumentReference
                storeRef = Firestore.firestore().collection("users").document(UserService.user.id).collection("reserveStore").document(self.clothes.tienda)
                let data1 = ReservaTienda.modelToData(reservaTienda: store)
                storeRef.setData(data1, merge: true) { (error) in
                    if let error = error {
                        self.handleError(error: error, msg: "No se puede subir el documento")
                        return
                    }
                }
                docRef = Firestore.firestore().collection("users").document(UserService.user.id).collection("reserveStore").document(self.clothes.tienda).collection("cart").document()
                reserves.id = docRef.documentID
                let data = Reserved.modelToData(reserve: reserves)
                docRef.setData(data, merge: true) { (error) in
                    if let error = error {
                        self.handleError(error: error, msg: "No se puede subir el documento")
                        return
                    }
                }
            }))
            reserveAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
                reserveAlert.dismiss(animated: true, completion: nil)
            }))
            present(reserveAlert, animated: true, completion: nil)
            
        } else {
            simpleAlert(title: "Error", msg: "La prenda se encuentra fuera de stock")
        }
        
    }
    
    func handleError(error : Error, msg : String){
        debugPrint(error.localizedDescription)
        simpleAlert(title: "Error", msg: msg)
    }
    @IBAction func dismissProduct(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func getCurrentAUser() {
        guard let authUser = Auth.auth().currentUser else { simpleAlert(title: "error", msg: "userError"); return }
        let userRef = Firestore.firestore().collection("users").document(authUser.uid)
        userListener = userRef.addSnapshotListener({ (snap, error) in
            if let error = error{
                debugPrint(error.localizedDescription)
            }
            guard let data = snap?.data() else { return }
            self.user = User.init(data: data)
            self.username = self.user.username
            self.phoneNumber = self.user.phoneNumber
        })
    }
}
extension ProductDetailVC : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == colorsPickerView {
            return clothes.colors.count
        } else if pickerView == sizesPickerView {
            return clothes.sizes.count
        }
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == colorsPickerView {
            return clothes.colors[row]
        } else if pickerView == sizesPickerView {
            return clothes.sizes[row]
        }
        return ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == colorsPickerView {
            color = clothes.colors[row]
            colorsLbl.text = clothes.colors[row]
        } else if pickerView == sizesPickerView {
            size = clothes.sizes[row]
            sizesLbl.text = clothes.sizes[row]
        }
    }
}
