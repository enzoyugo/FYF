//
//  MasFotosVC.swift
//  FYF Beta
//
//  Created by enzo on 4/6/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit
import Firebase

class MasFotosVC: UIViewController {
    var clothes : Clothes!
    @IBOutlet weak var photosCollView: UICollectionView!
    @IBOutlet weak var clothesLbl: UILabel!
    var db = Firestore.firestore()
    var listener : ListenerRegistration!
    var photo = [Photos]()
    override func viewDidLoad() {
        super.viewDidLoad()
        clothesLbl.text = clothes.name
        photosCollView?.register(UINib(nibName: "MasFotosCollViewCell", bundle: nil), forCellWithReuseIdentifier: "MasFotosCollViewCell")
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        getRowData()
    }
    override func viewDidDisappear(_ animated: Bool) {
        listener.remove()
        photo.removeAll()
        photosCollView?.reloadData()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func getRowData(){
        listener = db.collection("ClothesPhotos").whereField("clothesId", isEqualTo: clothes.id).whereField("onOff", isEqualTo: true).addSnapshotListener({ (snap, error) in
            
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let photo = Photos.init(data: data)
                
                switch change.type {
                    case.added:
                        self.onDocumentAdded(change: change, category: photo)
                    case.modified:
                        self.onDocumentModified(change: change, category: photo)
                    case.removed:
                        self.onDocumentRemoved(change: change)
                    
                }
            })
            
        })
        photo.removeAll()
        photosCollView?.reloadData()
    }
    
    func onDocumentAdded(change: DocumentChange, category: Photos){
        let newIndex = Int(change.newIndex)
        photo.insert(category, at: newIndex)
        photosCollView?.insertItems(at: [IndexPath(item: newIndex, section: 0)])
        
    }
    func onDocumentModified(change: DocumentChange, category: Photos){
        if change.newIndex == change.oldIndex {
            let index = Int(change.newIndex)
            photo[index] = category
            photosCollView?.reloadItems(at: [IndexPath(item: index, section: 0)])
            
        } else {
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            photo.remove(at: oldIndex)
            photo.insert(category, at: newIndex)
            
            photosCollView?.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
        }
    }
    func onDocumentRemoved(change: DocumentChange){
        let oldIndex = Int(change.oldIndex)
        photo.remove(at: Int(oldIndex))
        photosCollView?.deleteItems(at: [IndexPath(row: oldIndex, section: 0)])
    }
}
extension MasFotosVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MasFotosCollViewCell", for: indexPath) as? MasFotosCollViewCell{
            cell.configureCell(photo: photo[indexPath.item])
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width - 10, height: self.photosCollView.frame.size.height - 10)
    }
    
    
    
}
