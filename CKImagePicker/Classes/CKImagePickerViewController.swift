//
//  CKImagePickerViewController.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/3/16.
//
//

import UIKit
import AVFoundation
import Foundation

public protocol CKImagePickerProtocal {
    func imageCountChanges(count: Int)
}

public class CKImagePickerViewController: UIViewController {
    var imagePickerView: CKImagePickerView! { return self.view as! CKImagePickerView }
    private var configuration: CKImagePickerConfiguration!
    public var delegate: CKImagePickerProtocal!

    public var imageCount : Int {
        didSet {
            if (delegate != nil) {
                delegate.imageCountChanges(imageCount)
            }
        }
    }

    override public func loadView() {
        view = CKImagePickerView(frame: self.configuration.frame, configuration: self.configuration)
    }
    
    public init(configuration: CKImagePickerConfiguration) {
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        self.configuration = configuration
        self.imageCount = 0
        super.init(nibName: nil, bundle: nil)
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let dataPath = documentsDirectory.stringByAppendingPathComponent(configuration.imageFolderName)
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    public override func viewDidLoad() {
        imagePickerView.delegate = self
        imagePickerView.cameraView.delegate = self
        imagePickerView.albumView.delegate = self
        imagePickerView.cameraButton.addTarget(self, action: #selector(CKImagePickerViewController.switchView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        imagePickerView.albumButton.addTarget(self, action: #selector(CKImagePickerViewController.switchView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        switchView(imagePickerView.cameraButton)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidAppear(animated: Bool) {
        imagePickerView.cameraView.initializeSession()
        imagePickerView.albumView.reloadImages()
        imageCount = imagePickerView.albumView.images.count
    }
}

extension CKImagePickerViewController: CKImagePickerViewDelegate {
    @objc func imageDeleted() {
        imagePickerView.albumView.reloadImages()
        imageCount = imagePickerView.albumView.images.count
    }
    
    @objc func cameraShotFinished(image: UIImage) {
        imagePickerView.albumView.resetSelectedImage()
        let imageData = NSData(data:UIImagePNGRepresentation(image)!)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let fullPath = documentsPath.stringByAppendingString("/\(configuration.imageFolderName)/\(NSDate().timeIntervalSince1970).jpg")

        do {
            try imageData.writeToFile(fullPath, options: .DataWritingAtomic)
        } catch {
            print("Error saving file at path: \(fullPath) with error: \(error)")
        }
        imagePickerView.albumView.reloadImages()
        imageCount = imagePickerView.albumView.images.count
    }

    @objc func switchView(button: UIButton) {
        if button.tag == CKImagePickerConfiguration.MenuMode.Camera.rawValue {
            imagePickerView.cameraButtonPressed()
        } else {
            imagePickerView.albumButtonPressed()
        }
    }
}