//
//  CKImagePickerViewController.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/3/16.
//
//

import UIKit

public class CKImagePickerViewController: UIViewController {
    var imagePickerView: CKImagePickerView! { return self.view as! CKImagePickerView }
    
    override public func loadView() {
        view = CKImagePickerView(frame: UIScreen.mainScreen().bounds)
    }
}