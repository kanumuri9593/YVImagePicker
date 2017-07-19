//
//  ViewController.swift
//  Test
//
//  Created by yeswanth varma on 7/14/17.
//  Copyright © 2017 DSNY. All rights reserved.
//

import UIKit
let studentAvatars:[UIImage] = [#imageLiteral(resourceName: "s1"),#imageLiteral(resourceName: "s2"),#imageLiteral(resourceName: "s3"),#imageLiteral(resourceName: "s4"),#imageLiteral(resourceName: "s5"),#imageLiteral(resourceName: "s6"),#imageLiteral(resourceName: "s7"),#imageLiteral(resourceName: "s8"),#imageLiteral(resourceName: "s9")]
class ViewController: UIViewController {
   let picker = YPImagePicker()
    @IBOutlet weak var avatar: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.showsVideo = true
         let gestureRecognizerOne = UITapGestureRecognizer(target: self, action: #selector(StudentSelected))
        avatar.addGestureRecognizer(gestureRecognizerOne)
        
        picker.didSelectImage = { img in
            self.avatar.image = img
        }
        picker.didSelectVideo = { (videoData, img) in
            
            self.avatar.image = img
            // video picked
        }

        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func StudentSelected (_ sender:AnyObject){
      present(picker, animated: true, completion: nil)
    }
}

