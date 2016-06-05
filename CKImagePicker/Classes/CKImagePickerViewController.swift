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
    private var configuration: CKImagePickerConfiguration!
    
    override public func loadView() {
        view = CKImagePickerView(frame: UIScreen.mainScreen().bounds, configuration: self.configuration)
    }
    
    public init(configuration: CKImagePickerConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}