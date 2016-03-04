//
//  CameraOverlay.swift
//  CameraTesting
//
//  Created by Chris Cantley on 3/3/16.
//  Copyright © 2016 Chris Cantley. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol CameraOverlayDelegate: class {
    func cameraOverlayImage(image:UIImage)
}

class CameraOverlay: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    var view : UIView!
    
    var delegate: CameraOverlayDelegate?
    
    internal var returnImage : UIImage!
    internal var previewView : UIView!
    internal var boxView:UIView!
    internal let myButton: UIButton = UIButton()
    
    //Camera Capture requiered properties
    internal var previewLayer:AVCaptureVideoPreviewLayer!
    internal var captureDevice : AVCaptureDevice!
    internal let session=AVCaptureSession()
    
    //This will hold the still image output.
    internal var stillImageOutput: AVCaptureStillImageOutput!
    
    
    init(parentView: UIView){
        self.view = parentView
        
        //Create the output container with settings to specify that we are getting a still Image, and that it is a JPEG.
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        //Now we are sticking the image into the above formatted container
        session.addOutput(stillImageOutput)
    }
    
    func showCameraView() {
        
        
        self.setupCameraView()
        self.setupAVCapture()
    }
    
    
    //This is from the code-generated button.
    func didPressTakePhoto(sender: UIButton) {
        
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    
                    //Get the image data
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    
                    //Put the image into the sample area.
                    self.delegate?.cameraOverlayImage(image)
                    
                    //stop the session
                    self.session.stopRunning()
                    
                    //Remove the views.
                    self.previewView.removeFromSuperview()
                    self.boxView.removeFromSuperview()
                    self.myButton.removeFromSuperview()
                    
                    
                }
            })
        }
    }
    
    
    
    
    
    func setupCameraView(){
        
        //Take boxView, and make it is big as the frame.
        self.boxView = UIView(frame: self.view.frame)
        self.boxView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1.0)
        
        //Add the new boxView
        self.view.addSubview(self.boxView)
        
        //Add Camera Preview View
        self.previewView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        self.previewView.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(previewView)
        
        
        //Add the button.
        myButton.frame = CGRectMake(0,0,200,40)
        myButton.backgroundColor = UIColor.redColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("press me", forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myButton.layer.cornerRadius = 20.0
        myButton.layer.position = CGPoint(x: self.view.frame.width/2, y:(self.view.frame.height - myButton.frame.height ) )
        myButton.addTarget(self, action: "didPressTakePhoto:", forControlEvents: .TouchUpInside)
        self.view.addSubview(myButton)
        
    }
    
    
    func setupAVCapture(){
        
        session.sessionPreset = AVCaptureSessionPresetPhoto;
        
        let devices = AVCaptureDevice.devices();
        
        // Loop through all the capture devices on this phone
        for device in devices {
            
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                
                // Finally check the position and confirm we've got the front camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        
                        //-> Now that we have the back of the camera, start a session.
                        beginSession()
                        break;
                    }
                }
            }
        }
    }
    
    // Sets up the session
    func beginSession(){
        
        var err : NSError? = nil
        var deviceInput:AVCaptureDeviceInput?
        
        //See if we can get input from the Capture device as defined in setupAVCapture()
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error as NSError {
            err = error
            deviceInput = nil
        }
        if err != nil {
            print("error: \(err?.localizedDescription)")
        }
        
        //If we can add input into the AVCaptureSession() then do so.
        if self.session.canAddInput(deviceInput){
            self.session.addInput(deviceInput)
        }
        
        
        //Now show layers that were setup in the previewView, and mask it to the boundary of the previewView layer.
        let rootLayer :CALayer = self.previewView.layer
        rootLayer.masksToBounds=true
        
        //put a live video capture based on the current session.
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session);
        self.previewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(self.previewLayer)
        
        session.startRunning()
        
    }
    

    
}

