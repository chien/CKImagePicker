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
        let fullPath = documentsPath.stringByAppendingString("/\(configuration.imageFolderName)/\(NSDate().timeIntervalSince1970).jpg")

        do {
            try imageData.writeToFile(fullPath, options: .DataWritingAtomic)
        } catch {
            print("Error saving file at path: \(fullPath) with error: \(error)")
        }

        do {
            let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let imageFolderUrl = documentsUrl.URLByAppendingPathComponent(configuration.imageFolderName, isDirectory: true)
            let imageUrls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(imageFolderUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())

            imagePickerView.albumView.images = imageUrls
                .filter{ $0.pathExtension! == "jpg" }
                .flatMap { NSData(contentsOfURL: $0) }
                .flatMap { UIImage(data: $0) }
            imagePickerView.albumView.reloadImages()
        } catch {
            print("error loading images")
        }
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