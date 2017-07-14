//
//  AvatarsVC.swift
//  Test
//
//  Created by yeswanth varma on 7/14/17.
//  Copyright © 2017 DSNY. All rights reserved.
//

import UIKit

class AvatarVC: UIViewController {

 override var prefersStatusBarHidden: Bool { return true }
    
    var v = AvatarView()
    var Avatars = [UIImage]()
    var originalImage = UIImage()
    var thumbImage = UIImage()
    var didSelectImage: ((UIImage, String) -> Void)?
    var SelectedAvatarID:String = "1"

    override func loadView() { view = v }
    
    required init(images: [UIImage]) {
        super.init(nibName: nil, bundle: nil)
        title = "Avatar"
        self.originalImage = images[0]
        self.Avatars = images
    }
    
    func thumbFromImage(_ img: UIImage) -> UIImage {
        let width: CGFloat = img.size.width / 5
        let height: CGFloat = img.size.height / 5
        UIGraphicsBeginImageContext(CGSize(width:width, height:height))
        img.draw(in: CGRect(x:0, y:0, width:width, height:height))
        let smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return smallImage!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       v.imageView.image = originalImage
       thumbImage = thumbFromImage(originalImage)
       v.collectionView.register(FilterCollectionViewCell.self, forCellWithReuseIdentifier: "FilterCell")
        v.collectionView.dataSource = self
       v.collectionView.delegate = self
       v.collectionView.selectItem(at: IndexPath(row: 0, section: 0),
                                    animated: false,
                                    scrollPosition: UICollectionViewScrollPosition.bottom)
        
    }
    
    func done() {
        didSelectImage?(v.imageView.image!, SelectedAvatarID)
    
    }
}

extension AvatarVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Avatars.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell",
                                                         for: indexPath) as? FilterCollectionViewCell {
            cell.name.text = "\(indexPath.row)"
            if let img = Avatars[indexPath.row] as? UIImage{
                cell.imageView.image = img
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

extension AvatarVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            DispatchQueue.main.async {
                self.v.imageView.image = self.Avatars[indexPath.row]
            }
        }
    }
}







