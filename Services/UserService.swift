//
//  UserService.swift
//  FYF Beta
//
//  Created by enzo on 3/24/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import Foundation
import Firebase


let UserService = _UserService()
final class _UserService {
    //vars
    var user = User()
    var likes = [Collections]()
    var savedCl = [Clothes]()
    var likedStores = [Tiendas]()
    var reservedClothes = [Clothes]()
    var reserve = [Reserved]()
    let auth = Auth.auth()
    let db = Firestore.firestore()
    var userListener : ListenerRegistration? = nil
    var likesListener : ListenerRegistration? = nil
    var likedStoresListener : ListenerRegistration? = nil
    
    func getCurrentUser() {
        guard let authUser = auth.currentUser else { return }
        
        let userRef = db.collection("users").document(authUser.uid)
        userListener = userRef.addSnapshotListener({ (snap, error) in
            if let error = error{
                debugPrint(error.localizedDescription)
                return
            }
            guard let data = snap?.data() else { return }
            self.user = User.init(data: data)
            print(self.user)
        })
        
        let likesRef = userRef.collection("collections")
        likesListener = likesRef.addSnapshotListener({ (snap, error) in
            if let error = error{
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documents.forEach({ (document) in
                let like = Collections.init(data: document.data())
                self.likes.append(like)
                
            })
        })
        let likedStoresRef = userRef.collection("likedStores")
        likedStoresListener = likedStoresRef.addSnapshotListener({ (snap, error) in
            if let error = error{
                debugPrint(error.localizedDescription)
                return
            }
            snap?.documents.forEach({ (document) in
                let like = Tiendas.init(data: document.data())
                self.likedStores.append(like)
                
            })
        })
    }
    func likeSelected(coll: Collections) {
        let likesRef = Firestore.firestore().collection("users").document(user.id).collection("collections")
        if likes.contains(coll){
            // remove
            likes.removeAll{ $0 == coll }
            likesRef.document(coll.id).delete()
        } else {
            //add
            likes.append(coll)
            let data = Collections.modelToData(coll: coll)
            likesRef.document(coll.id).setData(data)
        }
        
    }
    func likedStoreSelected(tienda: Tiendas) {
        let likesRef = Firestore.firestore().collection("users").document(user.id).collection("likedStores")
        if likedStores.contains(tienda){
            // remove
            likedStores.removeAll{ $0 == tienda }
            likesRef.document(tienda.id).delete()
        } else {
            //add
            likedStores.append(tienda)
            let data = Tiendas.modelToData(tienda: tienda)
            likesRef.document(tienda.id).setData(data)
        }
        
    }
    func logOutUser() {
        userListener?.remove()
        userListener = nil
        likesListener?.remove()
        likesListener = nil
        likedStoresListener?.remove()
        likedStoresListener = nil
        user = User()
        likes.removeAll()
    }
    
}
