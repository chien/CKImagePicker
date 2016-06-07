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
        button.titleLabel!.font = UIFont.fontAwesomeOfSize(configuration.cameraControlButtonSize*0.9)
        button.setTitle(title, forState: .Normal)
        button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 0.5 * configuration.cameraControlButtonSize
        button.layer.borderWidth = configuration.cameraControlButtonSize*0.1-1
        button.layer.borderColor = configuration.tintColor.CGColor
    }
    
    func configureUtilButton(button: UIButton, title: String, selector: Selector) {
        button.tintColor = UIColor.whiteColor()
        button.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        button.titleLabel!.font = UIFont.fontAwesomeOfSize(configuration.utilControlButtonSize*0.5)
        button.setTitle(title, forState: .Normal)
        button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 0.5 * configuration.utilControlButtonSize
        
        constrain(button) { buttonView in
            buttonView.width == self.configuration.utilControlButtonSize
            buttonView.height == self.configuration.utilControlButtonSize
            buttonView.bottom == buttonView.superview!.bottom - self.configuration.paddingSize
            buttonView.right == buttonView.superview!.right - self.configuration.paddingSize
        }
    }
    
    func enabledUtilButton(button: UIButton) {
        button.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        button.tintColor = configuration.tintColor
    }
    
    func disabledUtilButton(button: UIButton) {
        button.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        button.tintColor = UIColor.whiteColor()
    }
}