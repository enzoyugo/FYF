//
//  AddEditProductsVC.swift
//  FYF Beta Admin
//
//  Created by enzo on 3/21/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import Firebase

class AddEditProductsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var filtersView: RoundedShadowView!
    @IBOutlet weak var selectedFiltersLbl: UILabel!
    @IBOutlet weak var filtersTblView: UIPickerView!
    @IBOutlet weak var moreImgsImg: UIImageView!
    @IBOutlet weak var stockTxt: UITextField!
    @IBOutlet weak var filterCollView: UICollectionView!
    @IBOutlet weak var oldPriceLbl: UILabel!
    @IBOutlet weak var oldPriceTxt: UITextField?
    @IBOutlet weak var colorsTblView: UITableView!
    @IBOutlet weak var colorsText: UITextField!
    @IBOutlet weak var sizesTblView: UITableView!
    @IBOutlet weak var tagsTblView: UITableView!
    @IBOutlet weak var sizesText: UITextField!
    @IBOutlet weak var addProductBtn: RoundedButton!
    @IBOutlet weak var productNameTxt: UITextField!
    @IBOutlet weak var clothesImg : RoundedImageView!
    
    @IBOutlet weak var priceTxt: UITextField!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var Tags = [String]()
    var Sizes = [String]()
    var Colors = [String]()
    var filters : PromoTypes!
    var selectedFilter : TypesOfCLothing!
    var selectedCategory : Tiendas!
    var productToEdit : Clothes?
    var promos : Bool = false
    var name = ""
    var price = 0
    var oldPrice = 0
    var stock = 0
    var db = Firestore.firestore()
    var clothes : Clothes!
    var finalCl : Clothes!
    var clothess = [Clothes]()
    var clothesArray = [[String : Any]]()
    var filtArray = [[String : Any]]()
    var promosArray = [[String : Any]]()
    var filter : FilterClothes!
    var promosClothes : FilterClothes!
    var pickerViewSearchSelection : String!
    var pickerview1 = ""
    var pickerview2 = ""
    var pickerview3 = ""
    var picker1Options : [TypesSearch] = []
    var picker2Options : [DesignSearch] = []
    var picker3Options : [ColorSearch] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataFilter = SearchDataSet()
        picker1Options = dataFilter.searchTypes
        let firstValue = picker1Options[0].displayName
        picker2Options = dataFilter.getTypes(forCategoryTitle: firstValue)
        let secondValue = picker2Options[0].displayName
        picker3Options = dataFilter.getColors(forTypeTitle: secondValue)
        filtersTblView.delegate = self
        filtersTblView.dataSource = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(imgTapped(_:)))
        tap.numberOfTapsRequired = 1
        clothesImg.isUserInteractionEnabled = true
        clothesImg.clipsToBounds = true
        clothesImg.addGestureRecognizer(tap)
        tagsTblView?.register(UINib(nibName: "tagsCell", bundle: nil), forCellReuseIdentifier: "tagsCell")
        sizesTblView?.register(UINib(nibName: "tagsCell", bundle: nil), forCellReuseIdentifier: "tagsCell")
        colorsTblView?.register(UINib(nibName: "tagsCell", bundle: nil), forCellReuseIdentifier: "tagsCell")
        filterCollView?.register(UINib(nibName: Identifiers.EachStoreColl, bundle: nil), forCellWithReuseIdentifier: Identifiers.EachStoreColl)
        if let product = productToEdit {
            clothes = product
            let taps = UITapGestureRecognizer(target: self, action: #selector(newImgTapped(_:)))
            clothess.append(clothes)
            Sizes = product.sizes
            stockTxt.text = "\(Int(product.stock))"
            Colors = product.colors
            tap.numberOfTapsRequired = 1
            moreImgsImg.isUserInteractionEnabled = true
            moreImgsImg.clipsToBounds = true
            moreImgsImg.addGestureRecognizer(taps)
            productNameTxt.text = product.name
            priceTxt.text = ""
            oldPriceTxt?.text = "\(Int(product.price))"
            Tags = product.tags
            addProductBtn.setTitle("Guardar cambios", for: .normal)
            if let url = URL(string: product.imgClUrl){
                clothesImg.contentMode = .scaleAspectFill
                clothesImg.kf.setImage(with: url)
            }
        }
        addProductBtn.isEnabled = false
    }
    
    @objc func imgTapped(_ tap: UITapGestureRecognizer){
        launchImgPicker()
    }
    
    @objc func newImgTapped(_ tap: UITapGestureRecognizer){
        let refreshAlert = UIAlertController(title: "Mas Fotos", message: "Desea añadir una foto nueva o ver las solicitudes", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Nueva", style: .default, handler: { (action: UIAlertAction!) in
            let vc = NewPhotosVC()
            vc.clothes = self.productToEdit
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Solicitudes", style: .default, handler: { (action: UIAlertAction!) in
            let vc = MoreFotosVC()
            vc.clothes = self.productToEdit
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }))
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
            refreshAlert.dismiss(animated: true, completion: nil)
        }))
        present(refreshAlert, animated: true, completion: nil)
        
    }
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func addProductClicked(_ sender: Any) {
        self.activityIndicator.startAnimating()
        let refreshAlert = UIAlertController(title: "Subir", message: "Subir los documentos", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Doc1", style: .default, handler: { (action: UIAlertAction!) in
            self.uploadImageThenDoc()
            refreshAlert.dismiss(animated: true, completion: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Doc2", style: .default, handler: { (action: UIAlertAction!) in
            var docRef : DocumentReference!
            docRef = self.db.collection("Tiendas").document(self.selectedCategory.id)
            let clother = self.selectedCategory.Clothess
            let cloth = Clothes.modelToData(clothes: self.finalCl)
            for each in 0...self.selectedCategory.Clothess.count - 1 {
                let eachCl = Clothes.init(data: clother[each])
                if eachCl == self.productToEdit{
                    print(eachCl)
                } else {
                    let cl = Clothes.modelToData(clothes: eachCl)
                    self.clothesArray.append(cl)
                }
            }
            self.clothesArray.append(cloth)
            let store = Tiendas.init(name: self.selectedCategory.name, id: self.selectedCategory.id, imgUrl: self.selectedCategory.imgUrl, isActive: self.selectedCategory.isActive, timeStamp: self.selectedCategory.timeStamp, hombre: self.selectedCategory.hombre, mujer: self.selectedCategory.mujer, Clothess: self.clothesArray)
            let tienda = Tiendas.modelToData(tienda: store)
            docRef.setData(tienda, merge: true) { (error) in
                if let error = error{
                    debugPrint(error.localizedDescription)
                }
            }
            self.activityIndicator.stopAnimating()
            if self.promos == false{
                self.dismiss(animated: true, completion: nil)
                refreshAlert.dismiss(animated: true, completion: nil)
            } else if self.promos == true{
                refreshAlert.dismiss(animated: true, completion: nil)
            }
        }))
        if promos == true {
            refreshAlert.addAction(UIAlertAction(title: "Doc3", style: .default, handler: { (action: UIAlertAction!) in
                var filtRef : DocumentReference!
                for each in 0...self.filter.Clothes.count - 1 {
                    let eachCl = Clothes.init(data: self.filter.Clothes[each])
                    if eachCl == self.productToEdit{
                        print("off")
                    } else {
                        let cl = Clothes.modelToData(clothes: eachCl)
                        self.filtArray.append(cl)
                    }
                }
                let cloth = Clothes.modelToData(clothes: self.finalCl)
                self.filtArray.append(cloth)
                let filt = FilterClothes.init(Clothes: self.filtArray)
                let filtCl = FilterClothes.modelToData(clothes: filt)
                filtRef = self.db.collection("TypesOfClothing").document(self.filters.displayName)
                filtRef.setData(filtCl, merge: true) { (error) in
                    if let error = error{
                        debugPrint(error.localizedDescription)
                    }
                }
                for each in 0...self.promosClothes.Clothes.count - 1 {
                    let eachCl = Clothes.init(data: self.promosClothes.Clothes[each])
                    if eachCl == self.productToEdit{
                        print("off")
                    } else {
                        let cl = Clothes.modelToData(clothes: eachCl)
                        self.promosArray.append(cl)
                    }
                }
                
                var filterRef : DocumentReference!
                let promoCl = Clothes.modelToData(clothes: self.finalCl)
                self.promosArray.append(promoCl)
                let filter = FilterClothes.init(Clothes: self.promosArray)
                let filterCl = FilterClothes.modelToData(clothes: filter)
                if self.selectedCategory.mujer == true{
                    filterRef = self.db.collection("Promos").document("Promos")
                } else if self.selectedCategory.hombre == true{
                    filterRef = self.db.collection("Promos").document("PromosHombres")
                }
                filterRef.setData(filterCl, merge: true) { (error) in
                    if let error = error{
                        debugPrint(error.localizedDescription)
                    }
                }
                self.activityIndicator.stopAnimating()
                self.dismiss(animated: true, completion: nil)
            }))
        } else if promos == false{
            print("notPromos")
        }
        refreshAlert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action: UIAlertAction!) in
            self.activityIndicator.stopAnimating()
            refreshAlert.dismiss(animated: true, completion: nil)
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
        filterCollView?.reloadData()
    }
    func getpromos(completionHandler:@escaping (FilterClothes) -> Void){
        if selectedCategory.mujer == true{
            let promosRef : DocumentReference!
            promosRef = self.db.collection("Promos").document("Promos")
            promosRef.getDocument { (snap, error) in
                if let error = error{
                    debugPrint(error.localizedDescription)
                    return
                }
                let data = snap!.data()
                let promosCl = FilterClothes.init(data: data!)
                completionHandler(promosCl)
            }
        } else if selectedCategory.hombre == true{
            let promosRef : DocumentReference!
            promosRef = self.db.collection("Promos").document("PromosHombres")
            promosRef.getDocument { (snap, error) in
                if let error = error{
                    debugPrint(error.localizedDescription)
                    return
                }
                let data = snap!.data()
                let promosMan = FilterClothes.init(data: data!)
                completionHandler(promosMan)
            }
            
        }
        
    }
    let data = DataSet()
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.Types.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cellB = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.EachStoreColl, for: indexPath) as? EachStoreCollViewPicker{
            cellB.configureCell(clothingType: data.Types[indexPath.item])
            let view = UIView(frame: cellB.bounds)
            view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cellB.selectedBackgroundView = view
            return cellB
        }
        
        return UICollectionViewCell()
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width / 2) - 5, height: 40)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filtRef : DocumentReference!
        filtRef = db.collection("TypesOfClothing").document(data.Types[indexPath.item].displayName)
        filtRef.getDocument { (snap, error) in
            if let error = error{
                debugPrint(error.localizedDescription)
                return
            }
            let data = snap!.data()
            let filt = FilterClothes.init(data: data!)
            self.filter = filt
        }
        
        
        filters = data.Types[indexPath.item]
        addProductBtn.isEnabled = true
        return
    }
    @IBAction func showFiltersBtnPressed(_ sender: Any) {
        if  self.filtersView.isHidden == true{
            self.filtersView.isHidden = false
        } else {
            self.filtersView.isHidden = true
        }
    }
    let dataFilters = SearchDataSet()
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0{
            return picker1Options.count
        } else if component == 1 {
            return picker2Options.count
        } else {
            return picker3Options.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            
            return picker1Options[row].displayName
        } else if component == 1 {
            return picker2Options[row].displayName
        } else {
            return picker3Options[row].displayName
        }
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var title = UILabel()
        if let view = view {
            title = view as! UILabel
        }
        title.textAlignment = .center
        title.adjustsFontSizeToFitWidth = true
        title.minimumScaleFactor = 0.5
        title.font = UIFont(name: "Raleway", size: 20)
        if component == 0{
            
            title.text = picker1Options[row].displayName
        } else if component == 1 {
            title.text = picker2Options[row].displayName
        } else {
            title.text = picker3Options[row].displayName
        }
        return title
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
            let selectedType = pickerView.selectedRow(inComponent: 0)
            let design = dataFilters.getTypes(forCategoryTitle: picker1Options[selectedType].displayName)
            picker2Options = design
            let selectedDesign = pickerView.selectedRow(inComponent: 1)
            let colors = dataFilters.getColors(forTypeTitle: picker2Options[selectedDesign].displayName)
            picker3Options = colors
            self.pickerViewSearchSelection = "\(self.pickerview1)"
            self.pickerview1 = picker1Options[selectedType].displayName
            selectedFiltersLbl.text = "\(self.pickerview1)"
            pickerView.reloadAllComponents()
        } else if component == 1 {
            let selectedDesign = pickerView.selectedRow(inComponent: 1)
            let colors = dataFilters.getColors(forTypeTitle: picker2Options[selectedDesign].displayName)
            picker3Options = colors
            self.pickerview2 = picker2Options[row].displayName
            self.pickerViewSearchSelection = "\(self.pickerview1) \(self.pickerview2)"
            selectedFiltersLbl.text = "\(self.pickerview1) \(self.pickerview2)"
            pickerView.reloadAllComponents()
        } else {
            self.pickerview3 = picker3Options[row].displayName
            self.pickerViewSearchSelection = "\(self.pickerview1) \(self.pickerview2) \(self.pickerview3)"
            selectedFiltersLbl.text = "\(self.pickerview1) \(self.pickerview2) \(self.pickerview3)"
        }
    }
    @IBAction func addTagsTapped(_ sender: Any) {
        self.filtersView.isHidden = true
        guard let eachTag = self.pickerViewSearchSelection?.lowercased(), eachTag.isNotEmpty
            else {
                simpleAlert(title: "Campo vacio", msg: "Añadir filtros")
                return
        }
        Tags.append(eachTag)
        selectedFiltersLbl.text = ""
        
        self.tagsTblView?.reloadData()
    }
    
    @IBAction func addColorsTapped(_ sender: Any) {
        guard let eachColor = colorsText.text , eachColor.isNotEmpty
            else {
                simpleAlert(title: "Campo vacio", msg: "Añadir colores")
                return
        }
        Colors.append(eachColor)
        colorsText.text = ""
        print(Colors)
        self.colorsTblView?.reloadData()
    }
    @IBAction func addSizesTapped(_ sender: Any) {
        guard let eachSize = sizesText.text , eachSize.isNotEmpty
            else {
                simpleAlert(title: "Campo vacio", msg: "Añadir tamaños")
                return
        }
        Sizes.append(eachSize)
        sizesText.text = ""
        print(Sizes)
        self.sizesTblView?.reloadData()
    }
    
    func uploadImageThenDoc() {
        guard let image = clothesImg.image,
            let name = productNameTxt.text , name.isNotEmpty,
            let price = Int(priceTxt.text!), let oldPrice = Int(oldPriceTxt?.text! ?? "0")
            else {
                simpleAlert(title: "Campos vacios", msg: "Favor llenar todos los campos")
                return
        }
        if price < oldPrice {
            self.promos = true
        }
        self.name = name
        self.price = price
        self.oldPrice = oldPrice
        self.stock = Int(stockTxt.text!)!
        activityIndicator.startAnimating()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {return}
        
        let imageRef = Storage.storage().reference().child("/clothesImages/\(name).jpg")
        
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
    
    func uploadDocument(url: String?){
        let storename = selectedCategory.name.capitalized
        var docRef : DocumentReference!
        self.finalCl = Clothes.init(price: Double(price), oldPrice: Double(oldPrice), imgClUrl: url!, id: "", LessStock: 0, likes: 0, name: name, tienda: selectedCategory.id, tags: Tags, typeId: filters.displayName , sizes: Sizes, colors: Colors, stock: Double(stock), promos: promos, storeName: storename, storeLogo: selectedCategory.imgUrl)
        if let productToEdit = productToEdit {
            
            docRef = Firestore.firestore().collection("Clothes").document(productToEdit.id)
            self.finalCl.id = productToEdit.id
        } else {
            docRef = Firestore.firestore().collection("Clothes").document()
            self.finalCl.id = docRef.documentID
            
        }
        let data = Clothes.modelToData(clothes: self.finalCl)
        docRef.setData(data, merge: true) { (error) in
            if let error = error {
                self.handleError(error: error, msg: "No se puede subir el documento")
                return
            }
        }
        if promos == true{
            self.getpromos(completionHandler: { (PromosCl) in
                self.promosClothes = PromosCl
            })
            self.activityIndicator.stopAnimating()
        }
        self.activityIndicator.stopAnimating()
    }
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func handleError(error : Error, msg : String){
        debugPrint(error.localizedDescription)
        simpleAlert(title: "Error", msg: msg)
        activityIndicator.stopAnimating()
    }
}
extension AddEditProductsVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func launchImgPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        clothesImg.contentMode = .scaleAspectFill
        clothesImg.image = image
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
extension AddEditProductsVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tagsTblView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "tagsCell") as? tagsCell{
                cell.tagTxt.text = Tags[indexPath.row]
                return cell } else { return UITableViewCell() }
        } else if tableView == colorsTblView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "tagsCell") as? tagsCell{
                cell.tagTxt.text = Colors[indexPath.row]
                return cell } else { return UITableViewCell() }
        } else if tableView == sizesTblView {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "tagsCell") as? tagsCell{
                cell.tagTxt.text = Sizes[indexPath.row]
                return cell } else { return UITableViewCell() }
        } else { return UITableViewCell() }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tagsTblView {
            Tags.remove(at: indexPath.row)
            tableView.reloadData()
            return
        } else if tableView == colorsTblView {
            Colors.remove(at: indexPath.row)
            tableView.reloadData()
            return
        } else if tableView == sizesTblView {
            Sizes.remove(at: indexPath.row)
            tableView.reloadData()
            return
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tagsTblView {
            return Tags.count
        } else if tableView == colorsTblView {
            return Colors.count
        } else if tableView == sizesTblView {
            return Sizes.count
        }
        return 0
    }
}
