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
    
    
    let videoRangeSlider:ABVideoRangeSlider = {
    let abvc = ABVideoRangeSlider()
        return abvc
        
    }()
    
    let ThumbImage:UIImageView = {
        let Img = UIImageView()
       Img.layer.cornerRadius = 20
       return Img
    }()
    
    var ThumbPosition:Float64 =  2.0
    
    var VideoUrl:URL!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(videoRangeSlider)
        view.addSubview(ThumbImage)
        videoRangeSlider.anchor(nil, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 80, rightConstant: 15, widthConstant: 0, heightConstant: 80)
        ThumbImage.anchor(self.view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 250, heightConstant: 250)
        ThumbImage.anchorCenterXToSuperview()
        SetThumbImage(Url: VideoUrl, time: ThumbPosition)
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
    

    
    func cropVideo(sourceURL1: NSURL, statTime:Float, endTime:Float)
    {
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        let url = sourceURL1
        let asset = AVAsset(url: url as URL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        let start = statTime
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
                print("exported at \(outputURL)")
            case .failed:
                print("failed \(exportSession.error)")
                
            case .cancelled:
                print("cancelled \(exportSession.error)")
                
            default: break
            }
        }
        
    }
    
    func SetThumbImage(Url:URL, time:Float64){
    
        let thumbnail = ABVideoHelper.thumbnailFromVideo(videoUrl: Url,
                                                         time: CMTimeMake(Int64(time), 1))
        self.ThumbImage.image = thumbnail
    
    }

    
    // MARK: ABVideoRangeSlider Delegate - Returns time in seconds
    
    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
    }
    
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
      self.ThumbPosition = position
      SetThumbImage(Url: VideoUrl, time: ThumbPosition)
    }

}
