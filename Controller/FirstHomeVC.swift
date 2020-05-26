//
//  FirstHomeVC.swift
//  FYF Beta
//
//  Created by enzo on 3/22/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class FirstHomeVC: UIViewController, UITabBarDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    
    @IBOutlet weak var Center: UIView!
    @IBOutlet weak var verTodoImg: RoundedButton!
    @IBOutlet weak var masPopularesImg: UIImageView!
    @IBOutlet weak var masPopularesBtn: UIButton!
    @IBOutlet weak var verTodoBtn: UIButton!
    @IBOutlet weak var manImg: UIImageView!
    @IBOutlet weak var womanImg: UIImageView!
    @IBOutlet weak var manBtn: UIButton!
    @IBOutlet weak var womanBtn: UIButton!
    @IBOutlet weak var backHomeBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var feedCollView: UICollectionView!
    @IBOutlet weak var homeStackView: UIStackView!
    @IBOutlet weak var findYourFitTopHome: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var SettingsStack: UIStackView!
    var listener: ListenerRegistration!
    var db : Firestore!
    var clothes = [Clothes]()
    let myTabBar = UITabBar()
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabBar()
        db = Firestore.firestore()
        feedCollView.register(UINib(nibName: Identifiers.ClothingTypeCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.ClothingTypeCell)
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
    override func viewDidAppear(_ animated: Bool) {
        if UserService.userListener == nil{
            UserService.getCurrentUser()
            
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    func getRowData(){
        listener = db.collection("Clothes").order(by: "likes", descending: true) .addSnapshotListener({ (snap, error) in
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
        feedCollView?.reloadData()
    }
    
    func onDocumentAdded(change: DocumentChange, category: Clothes){
        let newIndex = Int(change.newIndex)
        clothes.insert(category, at: newIndex)
        feedCollView?.insertItems(at: [IndexPath(item: newIndex, section: 0)])
        
    }
    func onDocumentModified(change: DocumentChange, category: Clothes){
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            clothes[index] = category
            feedCollView?.reloadItems(at: [IndexPath(item: index, section: 0)])
            
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            clothes.remove(at: oldIndex)
            clothes.insert(category, at: newIndex)
            
            feedCollView?.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        clothes.remove(at: Int(oldIndex))
        feedCollView?.deleteItems(at: [IndexPath(row: oldIndex, section: 0)])
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return clothes.count
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
    
    @IBAction func tengoUnaTienBtnPressed(_ sender: Any) {
        let appURL = URL(string: "mailto:contactos.findyourfit@gmail.com")!
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(appURL)
        }
    }
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag  {
            //            case 1:
            //                nil
            //                let controller = storyboard?.instantiateViewController(withIdentifier: "HomeNCVC")
            //                addChild(controller!)
            //                view.addSubview((controller?.view)!)
            //                controller?.didMove(toParent: self)
            //                break
            case 2:
                let controller = storyboard?.instantiateViewController(withIdentifier: "SearchVC")
                addChild(controller!)
                view.addSubview((controller?.view)!)
                controller?.didMove(toParent: self)
                break
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
    fileprivate func presentLoginController() {
        let storyboard = UIStoryboard(name: Storyboard.LoginStoryboard , bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: StoryboardId.LoginVC)
        self.navigationController?.isNavigationBarHidden = true
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func offSettingsPressed(_ sender: Any) {
        SettingsStack.isHidden = true
        myTabBar.isHidden = false
    }
    @IBAction func backHomeBtnClicked(_ sender: Any) {
        verTodoImg.isHidden = false
        masPopularesImg.isHidden = false
        verTodoBtn.isHidden = false
        masPopularesBtn.isHidden = false
        manImg.isHidden = false
        womanImg.isHidden = false
        manBtn.isHidden = false
        womanBtn.isHidden = false
        homeStackView.isHidden = false
        backHomeBtn.isHidden = true
        feedCollView.isHidden = true
        myTabBar.isHidden = false
        settingBtn.isHidden = false
        listener.remove()
        clothes.removeAll()
        feedCollView?.reloadData()
    }
    @IBAction func SettingsLogOut(_ sender: Any) {
        if let _ = Auth.auth().currentUser {
            do{
                try Auth.auth().signOut()
                UserService.logOutUser()
            } catch {
                
                Auth.auth().handleFireAuthError(error: error, vc: self)
            }
        } else { presentLoginController()
        }
    }
    func hideTabBar(){
        
    }
    @IBAction func settingsClicked(_ sender: Any) {
        SettingsStack.isHidden = false
        myTabBar.isHidden = true
        
        let Height = (view.frame.height / 3)
        SettingsStack.frame.size = CGSize(width: view.frame.width , height: Height)
    }
    
    @IBAction func logOutClicked(_ sender: Any) {
        if let _ = Auth.auth().currentUser {
            do{
                try Auth.auth().signOut()
            } catch {
                Auth.auth().handleFireAuthError(error: error, vc: self)
            }
        } else { presentLoginController()
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.toLikes {
            if let destination = segue.destination as? HomeNCVC {
                destination.showLikes = true
            }
        }
    }
    
}
