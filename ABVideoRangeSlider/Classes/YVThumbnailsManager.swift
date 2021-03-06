//
//  ABThumbnailsHelper.swift
//  selfband
//
//  Created by Oscar J. Irun on 27/11/16.
//  Copyright © 2016 appsboulevard. All rights reserved.
//

import UIKit
import AVFoundation

class ABThumbnailsManager: NSObject {
    
    var thumbnailViews = [UIImageView]()

    private func addImagesToView(images: [UIImage], view: UIView, imgWidth:CGFloat){
        
        self.thumbnailViews.removeAll()
        var xPos: CGFloat = 0.0
        var width: CGFloat = imgWidth
        for image in images{
            DispatchQueue.main.async {
//                if xPos + view.frame.size.height < view.frame.width{
//                    width = view.frame.size.height
//                }else{
//                    width = view.frame.size.width - xPos
//                }
                print(width)
                let imageView = UIImageView(image: image)
                imageView.alpha = 0
                imageView.contentMode = UIViewContentMode.scaleAspectFill
                
                imageView.clipsToBounds = true
                
                imageView.frame = CGRect(x: xPos,
                                         y: 0.0,
                                         width: width,
                                         height: 80)
                self.thumbnailViews.append(imageView)
                
                
                view.addSubview(imageView)
                UIView.animate(withDuration: 0.2, animations: {() -> Void in
                    imageView.alpha = 1.0
                })
                view.sendSubview(toBack: imageView)
                xPos = xPos + width
            }
        }
    }
    
    private func thumbnailCount(inView: UIView) -> Int{
        print(inView.frame.size.width,inView.frame.size.height)
         let num = Double(inView.frame.size.width ) / Double(inView.frame.size.height)
        let n = num > 0 ? num : Double(UIScreen.main.bounds.width - 30) / Double(40)
        return Int(ceil(n))
    }
    
    func updateThumbnails(view: UIView, videoURL: URL, duration: Float64) {
        
        for view in self.thumbnailViews{
            DispatchQueue.main.async {
                view.removeFromSuperview()
            }
        }
        
        var thumbnails = [UIImage]()
        var offset: Float64 = 0
        let numberoOfImages = Int(ceil(Double(UIScreen.main.bounds.width - 30) / Double(duration))) + 1
        let imagesCount = self.thumbnailCount(inView: view)
        print(numberoOfImages, duration)
        for i in 0..<numberoOfImages{
            let thumbnail = ABVideoHelper.thumbnailFromVideo(videoUrl: videoURL,
                                                             time: CMTimeMake(Int64(offset), 1))
            offset = Float64(i) * (duration / Float64(numberoOfImages))
            thumbnails.append(thumbnail)
        }
        self.addImagesToView(images: thumbnails, view: view, imgWidth: CGFloat(offset))
    }
}
