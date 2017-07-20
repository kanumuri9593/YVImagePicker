//
//  YVVideoTrimVC.swift
//  Test
//
//  Created by yeswanth varma on 7/18/17.
//  Copyright © 2017 DSNY. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class YVVideoTrimVC:UIViewController, ABVideoRangeSliderDelegate{
    
    public var didTrimVideo:((URL, UIImage) -> Void)?
    let videoRangeSlider:ABVideoRangeSlider = {
    let abvc = ABVideoRangeSlider()
        abvc.backgroundColor = .black
        return abvc
        
    }()
    
    let ThumbImage:UIImageView = {
        let Img = UIImageView()
        Img.contentMode = .scaleAspectFit
       Img.layer.cornerRadius = 20
       return Img
    }()
    
    let WhiteView:UIView = {
    
    let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    var ThumbPosition:Float64 =  2.0
    var TrimStartTime:Float64 = 0.0
    var TrimEndTime:Float64 = 55.0
    var VideoUrl:URL!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.backgroundColor = .white
        view.addSubview(videoRangeSlider)
        view.addSubview(ThumbImage)
        view.addSubview(WhiteView)
        videoRangeSlider.anchor(nil, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.WhiteView.leftAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 80, rightConstant: 0                                         , widthConstant: 0, heightConstant: 80)
        WhiteView.anchor(nil, left: videoRangeSlider.rightAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 80, rightConstant: 0, widthConstant: 15, heightConstant: 80)
        ThumbImage.anchor(self.view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 250, heightConstant: 250)
        ThumbImage.anchorCenterXToSuperview()
        SetThumbImage(Url: VideoUrl, time: ThumbPosition)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(done))
    }
    
    func done() {
        cropVideo(sourceURL1: VideoUrl, startTime: Float(TrimStartTime), endTime: Float(TrimEndTime))
        
    }
    
    required init(VideoURL: URL) {
        self.VideoUrl = VideoURL
        videoRangeSlider.setVideoURL(videoURL: VideoURL)
                super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
         videoRangeSlider.delegate = self
         videoRangeSlider.minSpace = 30.0
        // Set initial position of Start Indicator
        videoRangeSlider.setStartPosition(seconds: 5.0)
        
        // Set initial position of End Indicator
        videoRangeSlider.setEndPosition(seconds: 35.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    func cropVideo(sourceURL1: URL, startTime:Float, endTime:Float){
    
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        let url = sourceURL1
        let asset = AVAsset(url: url as URL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        let start = startTime
        let end = endTime
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            let name = "YVImageSlider"
            outputURL = outputURL.appendingPathComponent("\(name).mov")
        }catch let error {
            print(error)
        }
        
        //Remove existing file
        _ = try? manager.removeItem(at: outputURL)
        
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeMPEG4
        
        let startTime = CMTime(seconds: Double(start), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(end), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously{
            switch exportSession.status {
            case .completed:
               self.didTrimVideo?(outputURL, self.ThumbImage.image!)
            case .failed:
                self.didTrimVideo?(sourceURL1, self.ThumbImage.image!)
                print("failed \(exportSession.error)")
            case .cancelled:
                self.didTrimVideo?(sourceURL1, self.ThumbImage.image!)
                print("cancelled \(exportSession.error)")
                
            default: break
            }
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func SetThumbImage(Url:URL, time:Float64){
    
        let thumbnail = ABVideoHelper.thumbnailFromVideo(videoUrl: Url,
                                                         time: CMTimeMake(Int64(time), 1))
        self.ThumbImage.image = thumbnail
    
    }

    
    // MARK: ABVideoRangeSlider Delegate - Returns time in seconds
    
    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        TrimStartTime = startTime
        TrimEndTime = endTime
    }
    
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
      self.ThumbPosition = position
      SetThumbImage(Url: VideoUrl, time: ThumbPosition)
    }

}
