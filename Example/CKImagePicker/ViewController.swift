//
//  ViewController.swift
//  CKImagePicker
//
//  Created by Chien Kuo on 06/03/2016.
//  Copyright (c) 2016 Chien Kuo. All rights reserved.
//

import UIKit
import CKImagePicker

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type: UIButtonType.System)
        button.setTitle("Open Image Picker", forState: UIControlState.Normal)
        button.frame = CGRectMake(80, 300, 300, 30)
        button.titleLabel!.textColor = UIColor.blackColor()
        view.addSubview(button)
        
        button.addTarget(self, action: #selector(ViewController.openImagePicker(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }

    func openImagePicker(sender: UIButton) {
        let configuration = CKImagePickerConfiguration(frame: UIScreen.mainScreen().bounds)
        let vc = CKImagePickerViewController(configuration: configuration)
        vc.delegate = self
        let alert = UIAlertView(title: "Current Image Count", message: "image count: \(vc.imageCount)", delegate: nil, cancelButtonTitle: "OK")
        alert.show()

        self.presentViewController(vc, animated: true, completion: nil)
    }
}

extension ViewController: CKImagePickerProtocal {
    func imageCountChanges(count: Int) {
        let alert = UIAlertView(title: "New Image", message: "image count: \(count)", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
}