//
//  StretchyHeaderCollView.swift
//  FYF Beta
//
//  Created by enzo on 3/18/20.
//  Copyright © 2020 enzo. All rights reserved.
//

import UIKit


class StretchyHeaderCollView: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: Identifiers.ClothingTypeCell, bundle: nil), forCellWithReuseIdentifier: "ClothesCell")
}
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ClothesCell", for: indexPath) as? RowColectionView{
            cell.clothesPriceLbl.text = "200.000"
            return cell
        
            
        }
        return UICollectionViewCell()
}
}
