//
//  YPImagePicker.swift
//  Fusuma
//
//  Created by Sacha Durand Saint Omer on 27/10/16.
//  Copyright © 2016 ytakzk. All rights reserved.
//

import UIKit
import AVFoundation

class YPImagePickerConfiguration {
    static let shared = YPImagePickerConfiguration()
    public var onlySquareImages = false
}

public class YPImagePicker: UINavigationController {
        
    public static var albumName = "Yeshu" {
        didSet { PhotoSaver.albumName = albumName }
    }
    
    
    public static var CustomImageSelectorName = "avatar" {
        didSet { PhotoSaver.albumName = albumName }
    }
    
    public var showsVideo = false
    public var showsCustomSelector = false
    public var showsFilters = true
    public var EnableVideoTrim = true
    
    public var onlySquareImages = false {
        didSet {
            YPImagePickerConfiguration.shared.onlySquareImages = onlySquareImages
        }
    }
    
    public var usesFrontCamera: Bool {
        get { return fusuma.usesFrontCamera }
        set { fusuma.usesFrontCamera = newValue }
    }
   
    
    
    public var didSelectImage: ((UIImage) -> Void)?
    public var didSelectVideo: ((Data, UIImage) -> Void)?
    
    private let fusuma = FusumaVC()
    
    public func preheat() {
        _ = self.view
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        fusuma.showsVideo = showsVideo
        fusuma.showAvatars = showsCustomSelector
        viewControllers = [fusuma]
        navigationBar.isTranslucent = false
        fusuma.didSelectImage = { [unowned self] pickedImage, isNewPhoto in
            
            let mode = self.fusuma.mode
            
            
            
            if self.showsFilters && mode != .avatar{
                let filterVC = FiltersVC(image:pickedImage)
                filterVC.didSelectImage = { filteredImage, isImageFiltered in
                    self.didSelectImage?(filteredImage)
                    if isNewPhoto || isImageFiltered {
                        PhotoSaver.trySaveImage(filteredImage)
                    }
                }
                
                // Use Fade transition instead of default push animation
                let transition = CATransition()
                transition.duration = 0.3
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionFade
                self.view.layer.add(transition, forKey: nil)
                self.pushViewController(filterVC, animated: false)
                
            } else {
                self.didSelectImage?(pickedImage)
                if isNewPhoto {
                    PhotoSaver.trySaveImage(pickedImage)
                }
            }
        }
        
        fusuma.didSelectVideo = { [unowned self] videoURL in
            
            if self.EnableVideoTrim && ABVideoHelper.videoDuration(videoURL: videoURL) > 60 {
                
                let v = YVVideoTrimVC(VideoURL: videoURL)
                
                v.didTrimVideo = { [unowned self] (trimeedVideoUrl , thumImg) in
                    
                self.CompressVideo(VideoUrl: trimeedVideoUrl, thumbImg: thumImg)
                    
                }
                
                // Use Fade transition instead of default push animation
                let transition = CATransition()
                transition.duration = 0.3
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionFade
                self.view.layer.add(transition, forKey: nil)
                //let vc = VideoTrimmerVC()
                self.pushViewController(v, animated: false)
            
            }else {
              let thumb = thunbmailFromVideoPath(videoURL)
                self.CompressVideo(VideoUrl: videoURL, thumbImg: thumb)
            }
            
            
        }
        //force fusuma load view
        _ = fusuma.view
    }
    
    func CompressVideo(VideoUrl:URL, thumbImg:UIImage) {
        
        // Compress Video to 640x480 format.
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let firstPath = paths.first {
            let path = firstPath + "/\(Int(Date().timeIntervalSince1970))temporary.mov"
            let uploadURL = URL(fileURLWithPath: path)
            let asset = AVURLAsset(url: VideoUrl)
            let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480)
            exportSession?.outputURL = uploadURL
            exportSession?.outputFileType = AVFileTypeQuickTimeMovie
            exportSession?.shouldOptimizeForNetworkUse = true //USEFUL?
            exportSession?.exportAsynchronously {
                switch exportSession!.status {
                case .completed:
                    if let videoData = FileManager.default.contents(atPath: uploadURL.path) {
                        DispatchQueue.main.async {
                            
                            self.didSelectVideo?(videoData, thumbImg)
                        }
                    }
                default:
                    // Fall back to default video size:
                    if let videoData = FileManager.default.contents(atPath: VideoUrl.path) {
                        DispatchQueue.main.async {
                            self.didSelectVideo?(videoData, thumbImg)
                        }
                    }
                }
            }
        }
    }
}



func thunbmailFromVideoPath(_ path: URL) -> UIImage {
    let asset = AVURLAsset(url: path, options: nil)
    let gen = AVAssetImageGenerator(asset: asset)
    gen.appliesPreferredTrackTransform = true
    let time = CMTimeMakeWithSeconds(0.0, 600)
    var actualTime = CMTimeMake(0, 0)
    let image: CGImage
    do {
        image = try gen.copyCGImage(at: time, actualTime: &actualTime)
        let thumbnail = UIImage(cgImage: image)
        return thumbnail
    } catch { }
    return UIImage()
}

extension UIViewController {
    class func loadFromNib<T: UIViewController>() -> T {
        return T(nibName: String(describing: self), bundle: nil)
    }
}

