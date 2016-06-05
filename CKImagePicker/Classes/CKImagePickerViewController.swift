//
//  CKImagePickerViewController.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/3/16.
//
//

import UIKit
import AVFoundation

public class CKImagePickerViewController: UIViewController {
    var imagePickerView: CKImagePickerView! { return self.view as! CKImagePickerView }
    private var configuration: CKImagePickerConfiguration!
    
    override public func loadView() {
        view = CKImagePickerView(frame: UIScreen.mainScreen().bounds, configuration: self.configuration)
    }
    
    public init(configuration: CKImagePickerConfiguration) {
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        imagePickerView.delegate = self
        imagePickerView.cameraView.delegate = self
        imagePickerView.cameraButton.addTarget(self, action: #selector(CKImagePickerViewController.switchView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        imagePickerView.albumButton.addTarget(self, action: #selector(CKImagePickerViewController.switchView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        switchView(imagePickerView.cameraButton)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidAppear(animated: Bool) {
        imagePickerView.cameraView.initializeSession()
    }
}

extension CKImagePickerViewController: CKImagePickerViewDelegate {
    @objc func cameraShotFinished(image: UIImage) {
        let imageData = NSData(data:UIImagePNGRepresentation(image)!)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let fullPath = documentsPath.stringByAppendingString("/yourNameImg.jpg")
        let result = imageData.writeToFile(fullPath, atomically: true)

        let imageFromPath = UIImage(contentsOfFile: fullPath)
        imagePickerView.albumView.images = [imageFromPath!]
        imagePickerView.albumView.reloadImages()
    }

    @objc func switchView(button: UIButton) {
        if button.tag == CKImagePickerConfiguration.MenuMode.Camera.rawValue {
            imagePickerView.albumView.hidden = true
            imagePickerView.cameraView.hidden = false
        } else {
            imagePickerView.albumView.hidden = false
            imagePickerView.cameraView.hidden = true
        }
    }
}