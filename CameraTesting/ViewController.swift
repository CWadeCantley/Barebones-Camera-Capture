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

    //Setting up the class reference.
    var cameraOverlay : CameraOverlay!

    //Connected to the UIViewController main view.
    @IBOutlet var getView: UIView!
    
    //Connected to an ImageView that will display the image when it is passed back to the delegate.
    @IBOutlet weak var imgShowImage: UIImageView!
    
    
    //Connected to the button that is pressed to bring up the camera view.
    @IBAction func btnPictureTouch(sender: AnyObject) {
        
        //Remove the image from the UIImageView and take another picture.
        self.imgShowImage.image = nil
        self.cameraOverlay.showCameraView()
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Pass in the target UIView which in this case is the main view
        self.cameraOverlay = CameraOverlay(parentView: getView)
        
        //Make this class the delegate for the instantiated class.  
        //That way it knows to receive the image when the user takes a picture
        self.cameraOverlay.delegate = self
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        //Nothing here but if you run out of memorry you might want to do something here.
        
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
        
        //Put the image passed up from the CameraOverlay class into the UIImageView
        self.imgShowImage.image = image
    }
    
    

}

