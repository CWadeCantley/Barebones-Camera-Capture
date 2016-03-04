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

//We want to pass an image up to the parent class once the image has been taken so the easiest way to send it up
// and trigger the placing of the image is through a delegate.
protocol CameraOverlayDelegate: class {
    func cameraOverlayImage(image:UIImage)
}

class CameraOverlay: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    
    //MARK: Internal Variables
    
    //Setting up the delegate reference to be used later.
    internal var delegate: CameraOverlayDelegate?
    
    
    //Varibles for setting the camera view
    internal var returnImage : UIImage!
    internal var previewView : UIView!
    internal var boxView:UIView!
    internal let myButton: UIButton = UIButton()
    
    //Setting up Camera Capture required properties
    internal var previewLayer:AVCaptureVideoPreviewLayer!
    internal var captureDevice : AVCaptureDevice!
    internal let session=AVCaptureSession()
    internal var stillImageOutput: AVCaptureStillImageOutput!
    
    //When we put up the camera preview and the button we have to reference a parent view so this will hold the
    // parent view passed into the class so that other methods can work with it.
    internal var view : UIView!
    

    
    //When this class is instantiated, we want to require that the calling class passes us
    //some view that we can tie the camera previewer and button to.
    
    //MARK: - Instantiation Methods
    init(parentView: UIView){
        
        //Instantiate the reference to the passed-in UIView
        self.view = parentView
        
        //We are doing the following here because this only needs to be setup once per instantiation.
        
        //Create the output container with settings to specify that we are getting a still Image, and that it is a JPEG.
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        //Now we are sticking the image into the above formatted container
        session.addOutput(stillImageOutput)
    }

    //MARK: - Public Functions
    func showCameraView() {
        
        //This handles showing the camera previewer and button
        self.setupCameraView()
        
        //This sets up the parameters for the camera and begins the camera session.
        self.setupAVCapture()
    }
    
    //MARK: - Internal Functions
    
    //When the user clicks the button, this gets the image, sends it up to the delegate, and shuts down all the Camera related views.
    internal func didPressTakePhoto(sender: UIButton) {
        
        //Create a media connection...
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            
            //Setup the orientation to be locked to portrait
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            
            //capture the still image from the camera
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    
                    //Get the image data
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    
                    //Pass the image up to the delegate.
                    self.delegate?.cameraOverlayImage(image)
                    
                    //stop the session
                    self.session.stopRunning()
                    
                    //Remove the views.
                    self.previewView.removeFromSuperview()
                    self.boxView.removeFromSuperview()
                    self.myButton.removeFromSuperview()
                    
                    //By this point the image has been handed off to the caller through the delegate and memory has been cleaned up.
                    
                }
            })
        }
    }
    

    internal func setupCameraView(){
        
        //Add a view that is big as the frame that acts as a background.
        self.boxView = UIView(frame: self.view.frame)
        self.boxView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1.0)
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
    
    
    internal func setupAVCapture(){
        
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
    internal func beginSession(){
        
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

