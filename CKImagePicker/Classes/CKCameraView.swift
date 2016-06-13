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

class CKCameraView: CKImagePickerBaseView, UIGestureRecognizerDelegate {
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
        self.session = nil
        super.init(frame: CGRectZero)
        self.configuration = configuration
        flashConfiguration()

        self.addSubview(previewViewContainer)
        self.addSubview(buttonViewContainer)
        buttonViewContainer.addSubview(shotButton)
        configureCameraButton(shotButton, title: String.fontAwesomeIconWithName(.Circle), selector: #selector(CKCameraView.shotButtonPressed(_:)))
        
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

        constrain(shotButton) { button in
            button.center == button.superview!.center
            button.width == configuration.cameraControlButtonSize
            button.height == configuration.cameraControlButtonSize
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stopSession() {
        if self.session == nil {
            return
        }
        self.session!.stopRunning()
        self.session     = nil
        self.device      = nil
        self.imageOutput = nil
    }

    func initializeSession() {
        enableCameraButton(self.shotButton)

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
            self.previewViewContainer.addSubview(flashButton)
            configureUtilButton(flashButton, title: String.fontAwesomeIconWithName(.Flash), selector: #selector(CKCameraView.flashButtonPressed(_:)))
            setFlashButton()
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
        disableCameraButton(self.shotButton)
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

                    let fixOrientationImage = resizedImage.fixOrientation()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        delegate.cameraShotFinished(fixOrientationImage)
                        
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
                    flashButtonOn()
                } else if mode == AVCaptureFlashMode.On {
                    device.flashMode = AVCaptureFlashMode.Off
                    flashButtonOff()
                }
                
                device.unlockForConfiguration()
            }
            
        } catch _ {
            flashButtonOff()
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
    
    func setFlashButton() {
        if !cameraIsAvailable() {
            flashButton.hidden = true
            return
        }

        do {
            if let device = device {
                guard device.hasFlash else { return }
                let mode = device.flashMode
                if mode == AVCaptureFlashMode.On {
                    flashButtonOn()
                } else if mode == AVCaptureFlashMode.Off {
                    flashButtonOff()
                }
            }
            
        } catch _ {
            return
        }
    }
    
    func flashButtonOn() {
        enabledUtilButton(flashButton)
    }
    
    func flashButtonOff() {
        disabledUtilButton(flashButton)
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

