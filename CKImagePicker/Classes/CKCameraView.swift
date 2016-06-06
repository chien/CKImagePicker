//
//  CKCameraView.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/5/16.
//
//

import UIKit
import AVFoundation
import Cartography
import FontAwesome_swift

@objc protocol CKCameraViewDelegate: class {
    func cameraShotFinished(image: UIImage)
}

class CKCameraView: UIView, UIGestureRecognizerDelegate {
    var configuration: CKImagePickerConfiguration!
    
    var previewViewContainer = UIView()
    var buttonViewContainer = UIView()
    var shotButton = UIButton(type: UIButtonType.System)
    var flashButton = UIButton(type: UIButtonType.System)
    
    var delegate: CKCameraViewDelegate? = nil
    
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    var imageOutput: AVCaptureStillImageOutput?
    var focusView: UIView?
    
    init(configuration: CKImagePickerConfiguration) {
        self.configuration = configuration
        self.session = nil
        super.init(frame: CGRectZero)
        
        previewViewContainer.backgroundColor = UIColor.grayColor()
        
        configureCameraButton(flashButton, title: String.fontAwesomeIconWithName(.Flash), selector: #selector(CKCameraView.flashButtonPressed(_:)))
        configureCameraButton(shotButton, title: String.fontAwesomeIconWithName(.CameraRetro), selector: #selector(CKCameraView.shotButtonPressed(_:)))
        
        flashConfiguration()

        self.addSubview(previewViewContainer)
        self.addSubview(buttonViewContainer)
        buttonViewContainer.addSubview(flashButton)
        buttonViewContainer.addSubview(shotButton)
        
        constrain(previewViewContainer, buttonViewContainer) { view, buttonSection in
            view.top == view.superview!.top
            view.left == view.superview!.left
            view.width == configuration.imageContainerSize
            view.height == configuration.imageContainerSize
            
            buttonSection.top == view.bottom
            buttonSection.left == view.superview!.left
            buttonSection.width == configuration.imageContainerSize
            buttonSection.height == configuration.controllerContainerHeight
        }
        
        constrain(flashButton, shotButton) { b1, b2 in
            b1.centerY == b1.superview!.centerY
            b2.centerY == b2.superview!.centerY

            b1.width == configuration.cameraControlButtonSize
            b1.height == configuration.cameraControlButtonSize
            b2.size == b1.size

            b1.right == b1.superview!.centerX - configuration.cameraControlButtonSize/2
            b2.left == b2.superview!.centerX + configuration.cameraControlButtonSize/2
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCameraButton(button: UIButton, title: String, selector: Selector) {
        button.tintColor = self.configuration.tintColor
        button.backgroundColor = self.configuration.backgroundColor
        button.titleLabel!.font = UIFont.fontAwesomeOfSize(30)
        button.setTitle(title, forState: .Normal)
        button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 0.5 * configuration.cameraControlButtonSize
        button.layer.borderWidth = 1
        button.layer.borderColor = self.configuration.tintColor.CGColor
    }

    func initializeSession() {
        if session != nil {
            return
        }
        
        // AVCapture
        self.session = AVCaptureSession()
        
        for device in AVCaptureDevice.devices() {
            
            if let device = device as? AVCaptureDevice where device.position == AVCaptureDevicePosition.Back {
                
                self.device = device
                
                if !device.hasFlash {
                    
                    flashButton.hidden = true
                }
            }
        }
        
        do {
            
            if let session = self.session {
                
                videoInput = try AVCaptureDeviceInput(device: device)
                
                session.addInput(videoInput)
                
                imageOutput = AVCaptureStillImageOutput()
                
                session.addOutput(imageOutput)
                
                let videoLayer = AVCaptureVideoPreviewLayer(session: session)
                videoLayer.frame = self.previewViewContainer.bounds
                videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                self.previewViewContainer.layer.addSublayer(videoLayer)
                
                session.startRunning()
                
            }
            
            // Focus View
            self.focusView         = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer      = UITapGestureRecognizer(target: self, action:#selector(CKCameraView.focus(_:)))
            tapRecognizer.delegate = self
            self.previewViewContainer.addGestureRecognizer(tapRecognizer)
            
        } catch {
            print("av session error")
        }
        
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.Authorized {
            session!.startRunning()
        } else if status == AVAuthorizationStatus.Denied || status == AVAuthorizationStatus.Restricted {
            session!.stopRunning()
        }
    }
    
    func shotButtonPressed(sender: UIButton) {
        
        guard let imageOutput = imageOutput else {
            
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            let videoConnection = imageOutput.connectionWithMediaType(AVMediaTypeVideo)
            
            imageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (buffer, error) -> Void in
                
                self.session?.stopRunning()
                
                let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                
                if let image = UIImage(data: data), let delegate = self.delegate {
                    
                    // Image size
                    let iw = image.size.width
                    let ih = image.size.height
                    
                    // Frame size
                    let sw = self.previewViewContainer.frame.width
                    
                    // The center coordinate along Y axis
                    let rcy = ih*0.5
                    
                    let imageRef = CGImageCreateWithImageInRect(image.CGImage, CGRect(x: rcy-iw*0.5, y: 0 , width: iw, height: iw))
                    
                    let resizedImage = UIImage(CGImage: imageRef!, scale: sw/iw, orientation: image.imageOrientation)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        delegate.cameraShotFinished(resizedImage)
                        
                        self.session     = nil
                        self.device      = nil
                        self.imageOutput = nil
                        
                        self.initializeSession()
                    })
                }
                
            })
            
        })
    }
    
    func flashButtonPressed(sender: UIButton) {
        
        if !cameraIsAvailable() {
            
            return
        }
        
        do {
            
            if let device = device {
                
                guard device.hasFlash else { return }
                
                try device.lockForConfiguration()
                
                let mode = device.flashMode
                
                if mode == AVCaptureFlashMode.Off {
                    device.flashMode = AVCaptureFlashMode.On
                    flashButton.backgroundColor = self.configuration.tintColor
                    flashButton.tintColor = self.configuration.backgroundColor
                } else if mode == AVCaptureFlashMode.On {
                    device.flashMode = AVCaptureFlashMode.Off
                    flashButton.backgroundColor = self.configuration.backgroundColor
                    flashButton.tintColor = self.configuration.tintColor
                }
                
                device.unlockForConfiguration()
                
            }
            
        } catch _ {
            flashButton.backgroundColor = self.configuration.backgroundColor
            flashButton.titleLabel?.textColor = self.configuration.tintColor
            return
        }
        
    }
}

private extension CKCameraView {
    
    @objc func focus(recognizer: UITapGestureRecognizer) {
        
        let point = recognizer.locationInView(self)
        let viewsize = self.bounds.size
        let newPoint = CGPoint(x: point.y/viewsize.height, y: 1.0-point.x/viewsize.width)
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            
            try device.lockForConfiguration()
            
        } catch _ {
            
            return
        }
        
        if device.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) == true {
            
            device.focusMode = AVCaptureFocusMode.AutoFocus
            device.focusPointOfInterest = newPoint
        }
        
        if device.isExposureModeSupported(AVCaptureExposureMode.ContinuousAutoExposure) == true {
            
            device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
            device.exposurePointOfInterest = newPoint
        }
        
        device.unlockForConfiguration()
        
        self.focusView?.alpha = 0.0
        self.focusView?.center = point
        self.focusView?.backgroundColor = UIColor.clearColor()
        self.focusView?.layer.borderColor = configuration.tintColor.CGColor
        self.focusView?.layer.borderWidth = 1.0
        self.focusView!.transform = CGAffineTransformMakeScale(1.0, 1.0)
        self.addSubview(self.focusView!)
        
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.8,
                                   initialSpringVelocity: 3.0, options: UIViewAnimationOptions.CurveEaseIn, // UIViewAnimationOptions.BeginFromCurrentState
            animations: {
                self.focusView!.alpha = 1.0
                self.focusView!.transform = CGAffineTransformMakeScale(0.7, 0.7)
            }, completion: {(finished) in
                self.focusView!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.focusView!.removeFromSuperview()
        })
    }
    
    func flashConfiguration() {
        
        do {
            
            if let device = device {
                
                guard device.hasFlash else { return }
                
                try device.lockForConfiguration()
                
                device.flashMode = AVCaptureFlashMode.Off
                
                device.unlockForConfiguration()
                
            }
            
        } catch _ {
            
            return
        }
    }
    
    func cameraIsAvailable() -> Bool {
        
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.Authorized {
            
            return true
        }
        
        return false
    }
}

