//
//  AvatarView.swift
//  Test
//
//  Created by yeswanth varma on 7/14/17.
//  Copyright © 2017 DSNY. All rights reserved.
//

import Stevia

class AvatarView: UIView {
    
    let imageView = UIImageView()
    var collectionView: UICollectionView!
    
    convenience init() {
        self.init(frame: CGRect.zero)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout())
        
        sv(
            imageView,
            collectionView
        )
        
        let isIphone4 = UIScreen.main.bounds.height == 480
        let sideMargin: CGFloat = isIphone4 ? 20 : 0
        
        layout(
            0,
            |-sideMargin-imageView-sideMargin-|,
            0,
            |collectionView|,
            0
        )
        imageView.heightEqualsWidth()
        
        backgroundColor = UIColor(r: 247, g: 247, b: 247)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        layout.itemSize = CGSize(width: 100, height: 120)
        return layout
    }
}

