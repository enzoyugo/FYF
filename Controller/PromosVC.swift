//
//  PromosVC.swift
//  FYF Beta
//
//  Created by enzo on 3/22/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase


class PromosVC: UIViewController, UITabBarDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var hombresBtn: RoundedButton!
    @IBOutlet weak var mujeresBtn: RoundedButton!
    @IBOutlet weak var promosCollView: UICollectionView!
    var db = Firestore.firestore()
    var clothes = [Clothes]()
    var listener : ListenerRegistration!
    var allCl : FilterClothes!
    let myTabBar = UITabBar()
    override func viewDidLoad() {
        super.viewDidLoad()
        addTabBar()
        promosCollView?.register(UINib(nibName: Identifiers.ClothingTypeCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.ClothingTypeCell)
        @IBAction func hombresBtnPressed(_ sender: Any) {
            
            listener = db.collection("Promos").document("PromosHombres").addSnapshotListener({ (snap, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                let data = snap!.data()
                let allCl = FilterClothes.init(data: data!)
                self.allCl = allCl
                self.promosCollView?.reloadData()
            })
        }
        @IBAction func mujeresBtnPressed(_ sender: Any) {
            listener = db.collection("Promos").document("Promos").addSnapshotListener({ (snap, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                let data = snap!.data()
                let allCl = FilterClothes.init(data: data!)
                self.allCl = allCl
                self.promosCollView?.reloadData()
            })
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
            getRowData()
        }
        override func viewDidDisappear(_ animated: Bool) {
            listener.remove()
            clothes.removeAll()
            promosCollView?.reloadData()
        }
        func getRowData(){
            listener = db.collection("Promos").document("Promos").addSnapshotListener({ (snap, error) in
                if let error = error {
                    debugPrint(error.localizedDescription)
                    return
                }
                let data = snap!.data()
                let allCl = FilterClothes.init(data: data!)
                self.allCl = allCl
                self.promosCollView?.reloadData()
            })
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if let allCl = allCl{
                return allCl.Clothes.count
            }
            else {
                return 0
            }
        }
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.ClothingTypeCell, for: indexPath) as? RowColectionView{
                let clothes = Clothes.init(data: allCl.Clothes[indexPath.item])
                cell.configureCell(clothes: clothes)
                return cell
                
            } else{ return UICollectionViewCell()
                
            }
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: (160), height: 240)
        }
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let vc = ProductDetailVC()
            let selectedClothes = Clothes.init(data: allCl.Clothes[indexPath.item])
            vc.clothes = selectedClothes
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
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
                //                           case 3:
                //                           let controller = storyboard?.instantiateViewController(withIdentifier: "PromosVC")
                //                           addChild(controller!)
                //                           view.addSubview((controller?.view)!)
                //                           controller?.didMove(toParent: self)
                //                           break
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
}
