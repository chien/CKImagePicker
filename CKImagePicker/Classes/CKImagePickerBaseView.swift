//
//  CKImagePickerBaseView.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/6/16.
//
//

import UIKit
import FontAwesome_swift
import Cartography

public class CKImagePickerBaseView: UIView {
    var configuration: CKImagePickerConfiguration!
    
    func configureCameraButton(button: UIButton, title: String, selector: Selector) {
        button.tintColor = configuration.tintColor
        button.backgroundColor = configuration.backgroundColor
        button.titleLabel!.font = UIFont.fontAwesomeOfSize(57)
        button.setTitle(title, forState: .Normal)
        button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 0.5 * configuration.cameraControlButtonSize
        button.layer.borderWidth = 5
        button.layer.borderColor = configuration.tintColor.CGColor
    }
    
    func configureUtilButton(button: UIButton, title: String, selector: Selector) {
        button.tintColor = configuration.tintColor
        button.backgroundColor = configuration.utilButtonBackgroundColor
        button.titleLabel!.font = UIFont.fontAwesomeOfSize(15)
        button.setTitle(title, forState: .Normal)
        button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 0.5 * configuration.utilControlButtonSize
        button.layer.borderWidth = 1
        button.layer.borderColor = configuration.tintColor.CGColor
        
        constrain(button) { buttonView in
            buttonView.width == self.configuration.utilControlButtonSize
            buttonView.height == self.configuration.utilControlButtonSize
            buttonView.bottom == buttonView.superview!.bottom - self.configuration.paddingSize
            buttonView.right == buttonView.superview!.right - self.configuration.paddingSize
        }
    }
}