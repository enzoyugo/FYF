//
//  SearchVC.swift
//  FYF Beta
//
//  Created by enzo on 3/22/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class SearchVC: UIViewController, UITabBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var noResultsLabel: RoundedLabel!
    @IBOutlet weak var filtersLbl: UILabel!
    @IBOutlet weak var filtersView: RoundedShadowView!
    @IBOutlet weak var searchPickerView: UIPickerView!
    @IBOutlet weak var promosOnOff: UISwitch!
    @IBOutlet weak var searchCollView: UICollectionView!
    var promos : Bool = false
    var set : Query!
    var allTags = [[String]]()
    var Tags = [String]()
    var listener : ListenerRegistration!
    var db = Firestore.firestore()
    var clothes = [Clothes]()
    var searchPressed : Bool = false
    var pickerViewSearchSelection : String!
    var pickerview1 = ""
    var pickerview2 = ""
    var pickerview3 = ""
    var picker1Options : [TypesSearch] = []
    var picker2Options : [DesignSearch] = []
    var picker3Options : [ColorSearch] = []
    let myTabBar = UITabBar()
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabBar()
        searchCollView?.register(UINib(nibName: Identifiers.ClothingTypeCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.ClothingTypeCell)
        let data = SearchDataSet()
        picker1Options = data.searchTypes
        let firstValue = picker1Options[0].displayName
        picker2Options = data.getTypes(forCategoryTitle: firstValue)
        let secondValue = picker2Options[0].displayName
        picker3Options = data.getColors(forTypeTitle: secondValue)
        if promosOnOff.isOn {
            promos = true
        } else {
            promos = false
        }
        searchPickerView.delegate = self
        searchPickerView.dataSource = self
    }
    func addTabBar() -> Void{
        self.view.addSubview(myTabBar)
        self.myTabBar.translatesAutoresizingMaskIntoConstraints = false
        self.myTabBar.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.myTabBar.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.myTabBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.myTabBar.barTintColor = AppColors.DarkGray
        self.myTabBar.unselectedItemTintColor = AppColors.GrayBck
        self.myTabBar.tintColor = .white
        let one = UITabBarItem()
        one.image = #imageLiteral(resourceName: "home")
        one.tag = 1
        let two = UITabBarItem()
        two.image = #imageLiteral(resourceName: "search")
        two.tag = 2
        let three = UITabBarItem()
        three.image = #imageLiteral(resourceName: "promos")
        three.tag = 3
        let four = UITabBarItem()
        four.image = #imageLiteral(resourceName: "profile")
        four.tag = 4
        self.myTabBar.setItems([one,two, three, four], animated: false)
        
        self.myTabBar.delegate = self
        self.view.bringSubviewToFront(self.myTabBar)
        
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addHeightConstraintToTabBar()
    }
    func addHeightConstraintToTabBar() -> Void {
        let heightConstant: CGFloat = self.view.safeAreaInsets.bottom + 49.0
        self.myTabBar.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    @IBAction func filtersBtnPressed(_ sender: Any) {
        if filtersView.isHidden == true{
            filtersView.isHidden = false
        } else {
            filtersView.isHidden = true
        }
        if noResultsLabel.isHidden == true{
            noResultsLabel.isHidden = true
        } else {
            noResultsLabel.isHidden = true
        }
    }
    @IBAction func searchBtnPressed(_ sender: Any) {
        if promosOnOff.isOn {
            promos = true
        } else {
            promos = false
        }
        if filtersView.isHidden == false{
            filtersView.isHidden = true
        }
        if promos == false {
            getSearchData(){
                self.searchPressed = true
            }
        } else {
            getSearchBData(){
                self.searchPressed = true
            }
        }
        searchCollView?.reloadData()
        view.endEditing(true)
    }
    override func viewDidDisappear(_ animated: Bool) {
        listener?.remove()
        clothes.removeAll()
        searchCollView.reloadData()
    }
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag  {
            case 1:
                let controller = storyboard?.instantiateViewController(withIdentifier: "FirstHomeVC")
                addChild(controller!)
                view.addSubview((controller?.view)!)
                controller?.didMove(toParent: self)
                break
            //                      case 2:
            //                          let controller = storyboard?.instantiateViewController(withIdentifier: "SearchVC")
            //                          addChild(controller!)
            //                          view.addSubview((controller?.view)!)
            //                          controller?.didMove(toParent: self)
            //                          break
            case 3:
                let controller = storyboard?.instantiateViewController(withIdentifier: "PromosVC")
                addChild(controller!)
                view.addSubview((controller?.view)!)
                controller?.didMove(toParent: self)
                break
            case 4:
                let controller = storyboard?.instantiateViewController(withIdentifier: "ProfileVC")
                addChild(controller!)
                view.addSubview((controller?.view)!)
                controller?.didMove(toParent: self)
                break
            default:
                break
        }
    }
    let data = SearchDataSet()
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
            let design = data.getTypes(forCategoryTitle: picker1Options[selectedType].displayName)
            picker2Options = design
            let selectedDesign = pickerView.selectedRow(inComponent: 1)
            let colors = data.getColors(forTypeTitle: picker2Options[selectedDesign].displayName)
            picker3Options = colors
            self.pickerViewSearchSelection = "\(self.pickerview1)"
            self.pickerview1 = picker1Options[selectedType].displayName
            filtersLbl.text = "\(self.pickerview1)"
            pickerView.reloadAllComponents()
        } else if component == 1 {
            let selectedDesign = pickerView.selectedRow(inComponent: 1)
            let colors = data.getColors(forTypeTitle: picker2Options[selectedDesign].displayName)
            picker3Options = colors
            self.pickerview2 = picker2Options[row].displayName
            self.pickerViewSearchSelection = "\(self.pickerview1) \(self.pickerview2)"
            filtersLbl.text = "\(self.pickerview1) \(self.pickerview2)"
            pickerView.reloadAllComponents()
        } else {
            self.pickerview3 = picker3Options[row].displayName
            self.pickerViewSearchSelection = "\(self.pickerview1) \(self.pickerview2) \(self.pickerview3)"
            filtersLbl.text = "\(self.pickerview1) \(self.pickerview2) \(self.pickerview3)"
        }
    }
    func getSearchBData(completion: () -> Void){
        guard let selection = self.pickerViewSearchSelection, selection.isNotEmpty
            else {
                simpleAlert(title: "Error", msg: "Seleccionar filtros")
                return
        }
        let docRef = db.collection("Clothes")
        
        docRef.whereField("tags", arrayContains: self.pickerViewSearchSelection!.lowercased()).whereField("promos", isEqualTo: true).order(by: "timeStamp", descending: true).addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let clothes = Clothes.init(data: data)
                
                switch change.type {
                    case.added:
                        self.onDocumentAdded(change: change, category: clothes)
                    case.modified:
                        self.onDocumentModified(change: change, category: clothes)
                    case.removed:
                        self.onDocumentRemoved(change: change)
                    
                }
            })
            
        })
        clothes.removeAll()
        searchCollView?.reloadData()
        completion()
    }
    func getSearchData(completion: () -> Void){
        guard let selection = self.pickerViewSearchSelection, selection.isNotEmpty
            else {
                simpleAlert(title: "Error", msg: "Seleccionar filtros")
                return
        }
        let docRef = db.collection("Clothes")
        
        docRef.whereField("tags", arrayContains: self.pickerViewSearchSelection!.lowercased()).order(by: "timeStamp", descending: true).addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let clothes = Clothes.init(data: data)
                
                switch change.type {
                    case.added:
                        self.onDocumentAdded(change: change, category: clothes)
                    case.modified:
                        self.onDocumentModified(change: change, category: clothes)
                    case.removed:
                        self.onDocumentRemoved(change: change)
                    
                }
            })
            
        })
        clothes.removeAll()
        searchCollView?.reloadData()
        completion()
    }
    
    func onDocumentAdded(change: DocumentChange, category: Clothes){
        let newIndex = Int(change.newIndex)
        clothes.insert(category, at: newIndex)
        searchCollView?.insertItems(at: [IndexPath(item: newIndex, section: 0)])
        
    }
    func onDocumentModified(change: DocumentChange, category: Clothes){
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            clothes[index] = category
            searchCollView?.reloadItems(at: [IndexPath(item: index, section: 0)])
            
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            clothes.remove(at: oldIndex)
            clothes.insert(category, at: newIndex)
            
            searchCollView?.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        clothes.remove(at: Int(oldIndex))
        searchCollView?.deleteItems(at: [IndexPath(row: oldIndex, section: 0)])
    }
}
extension SearchVC : UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.searchPressed == true && clothes.count >= 1{
            self.noResultsLabel.isHidden = true
            return clothes.count
        } else {
            if self.searchPressed == true && self.clothes.count == 0{
                self.noResultsLabel.isHidden = false
                
            }
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.ClothingTypeCell, for: indexPath) as? RowColectionView{
            cell.configureCell(clothes: clothes[indexPath.item])
            return cell
            
        } else{ return UICollectionViewCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (160), height: 240)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ProductDetailVC()
        let selectedClothes = clothes[indexPath.item]
        vc.clothes = selectedClothes
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
}
extension SearchVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "tagsCell") as? tagsCell{
            cell.tagTxt.text = Tags[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        allTags.remove(at: indexPath.row)
        Tags.remove(at: indexPath.row)
        tableView.reloadData()
        return
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTags.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}
