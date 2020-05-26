//
//  ProfileVC.swift
//  FYF Beta
//
//  Created by enzo on 3/22/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController, UITabBarDelegate {
    
    @IBOutlet weak var usernameProPic: CirlclImageView!
    @IBOutlet weak var profileCollView: UICollectionView!
    @IBOutlet weak var usernameLbl: UILabel!
    var listener : ListenerRegistration!
    var clothes = [Clothes]()
    var coll = [Collections]()
    var ref: Query!
    var user = User()
    var userListener : ListenerRegistration!
    var selectedColls : Collections!
    let myTabBar = UITabBar()
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabBar()
        profileCollView?.register(UINib(nibName: Identifiers.ProfileCollCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.ProfileCollCell)
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
    @IBAction func editPrfileBtnWasPressed(_ sender: Any) {
        let vc = EditProfileVC()
        vc.selectedUser = user
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        if UserService.userListener == nil{
            UserService.getCurrentUser()
        }
        getLikes()
        profileCollView?.reloadData()
        getCurrentAUser()
    }
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        coll.removeAll()
        profileCollView?.reloadData()
    }
    @IBAction func newColl(_ sender: Any) {
        let vc = NewCollVC()
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
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
            self.usernameLbl.text = self.user.username
            self.usernameProPic.setTitle("\(self.user.username.uppercased().prefix(1))", for: UIControl.State.normal)
        })
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag  {
            case 1:
                let controller = storyboard?.instantiateViewController(withIdentifier: "FirstHomeVC")
                addChild(controller!)
                view.addSubview((controller?.view)!)
                controller?.didMove(toParent: self)
                break
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
            //                    case 4:
            //                    let controller = storyboard?.instantiateViewController(withIdentifier: "ProfileVC")
            //                    addChild(controller!)
            //                    view.addSubview((controller?.view)!)
            //                    controller?.didMove(toParent: self)
            //                    break
            default:
                break
        }
    }
    func getLikes(){
        ref = Firestore.firestore().collection("users").document(UserService.user.id).collection("collections")
        listener = ref.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let coll = Collections.init(data: data)
                
                switch change.type {
                    case.added:
                        self.onDocumentAdded(change: change, category: coll)
                    case.modified:
                        self.onDocumentModified(change: change, category: coll)
                    case.removed:
                        self.onDocumentRemoved(change: change)
                    
                }
            })
            
        })
        clothes.removeAll()
        profileCollView?.reloadData()
    }
    
    func onDocumentAdded(change: DocumentChange, category: Collections){
        let newIndex = Int(change.newIndex)
        coll.insert(category, at: newIndex)
        profileCollView?.insertItems(at: [IndexPath(item: newIndex, section: 0)])
        
    }
    func onDocumentModified(change: DocumentChange, category: Collections){
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            coll[index] = category
            profileCollView?.reloadItems(at: [IndexPath(item: index, section: 0)])
            
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            coll.remove(at: oldIndex)
            coll.insert(category, at: newIndex)
            
            profileCollView?.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        coll.remove(at: Int(oldIndex))
        profileCollView?.deleteItems(at: [IndexPath(row: oldIndex, section: 0)])
    }
}
extension ProfileVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coll.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.size.width / 2 ) - 20, height: view.frame.size.height / 4 )
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.ProfileCollCell, for: indexPath) as? ProfileCollCell{
            cell.configureCell(coll: coll[indexPath.row])
            return cell
            
        } else{
            return UICollectionViewCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColls = coll[indexPath.item]
        performSegue(withIdentifier: "toUsrColl", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUsrColl" {
            if let destination = segue.destination as? UsrCollVC {
                destination.selectedColl = selectedColls
            }
        }
    }
}
