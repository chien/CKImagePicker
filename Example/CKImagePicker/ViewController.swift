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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openImagePicker(sender: UIButton) {
        let vc = CKImagePickerViewController()
        self.presentViewController(vc, animated: true, completion: nil)
    }
}