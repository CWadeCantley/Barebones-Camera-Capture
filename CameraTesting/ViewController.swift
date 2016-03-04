//
//  ViewController.swift
//  CameraTesting
//
//  Created by Chris Cantley on 2/26/16.
//  Copyright © 2016 Chris Cantley. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, CameraOverlayDelegate{

    var cameraOverlay : CameraOverlay!

    @IBOutlet var getView: UIView!
    @IBOutlet weak var imgShowImage: UIImageView!
    
    
    @IBAction func btnPictureTouch(sender: AnyObject) {
        self.imgShowImage.image = nil
        self.cameraOverlay.showCameraView()
    }
    @IBAction func btnTakeAnother(sender: AnyObject) {
        //Remove image from preview
        self.imgShowImage.image = nil
        self.cameraOverlay.showCameraView()
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.cameraOverlay = CameraOverlay(parentView: getView)
        self.cameraOverlay.delegate = self
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldAutorotate() -> Bool {
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.Unknown) {
                return false;
        }
        else {
            return true;
        }
    }
    
    //This references the delegate from CameraOveralDelegate
    func cameraOverlayImage(image: UIImage) {
        self.imgShowImage.image = image
    }
    
    

}

