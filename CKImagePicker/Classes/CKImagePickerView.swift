//
//  CKImagePickerView.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/3/16.
//
//

import UIKit
import Cartography

protocol CKImagePickerViewDelegate {
    func switchView(button: UIButton)
}

public class CKImagePickerView: UIView {
    var configuration: CKImagePickerConfiguration!
    let constraintGroup = ConstraintGroup()

    let buttonSize = CGFloat(30.0)
    let buttonSpace = CGFloat(2.0)
    let albumView: CKAlbumView!
    let cameraView: CKCameraView!
    let contentContainer = UIView()

    // button section
    var buttonSectionView = UIView()
    var cameraButton = UIButton(type: UIButtonType.System)
    var albumButton = UIButton(type: UIButtonType.System)
    
    public init(frame: CGRect, configuration: CKImagePickerConfiguration) {
        self.configuration = configuration
        self.albumView = CKAlbumView(configuration: self.configuration)
        self.cameraView = CKCameraView(configuration: self.configuration)
        super.init(frame: frame)

        let buttonSectionHeight = buttonSize+2*buttonSpace
        self.addSubview(contentContainer)
        contentContainer.addSubview(albumView)
        contentContainer.addSubview(cameraView)
        contentContainer.backgroundColor = UIColor.whiteColor()

        // Button Section
        self.addSubview(buttonSectionView)
        buttonSectionView.backgroundColor = UIColor.blueColor()
        buttonSectionView.addSubview(cameraButton)
        buttonSectionView.addSubview(albumButton)
        
        cameraButton.backgroundColor = configuration.backgroundColor
        cameraButton.setTitle("Camera", forState: UIControlState.Normal)
        cameraButton.titleLabel!.textColor = configuration.textColor
        cameraButton.titleLabel!.font = configuration.font
        cameraButton.tag = CKImagePickerConfiguration.MenuMode.Camera.rawValue
        cameraButton.addTarget(self, action: #selector(CKImagePickerView.switchView(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        albumButton.backgroundColor = configuration.backgroundColor
        albumButton.setTitle("Album", forState: UIControlState.Normal)
        albumButton.tag = CKImagePickerConfiguration.MenuMode.Album.rawValue
        albumButton.titleLabel!.textColor = configuration.textColor
        albumButton.titleLabel!.font = configuration.font
        albumButton.addTarget(self, action: #selector(CKImagePickerView.switchView(_:)), forControlEvents: UIControlEvents.TouchUpInside)

        constrain(buttonSectionView, contentContainer) { view1, view2 in
            view2.top == view2.superview!.top
            view2.left == view2.superview!.left
            view2.width == view2.superview!.width
            view2.height == view2.superview!.height - buttonSectionHeight

            view1.top  == view2.bottom
            view1.left == view1.superview!.left
            view1.height == buttonSectionHeight
            view1.width == view1.superview!.width
        }
        
        constrain(cameraButton, albumButton) { camera, album in
            camera.bottom == camera.superview!.bottom - self.buttonSpace
            camera.left == camera.superview!.left + self.buttonSpace
            album.left == camera.right + self.buttonSpace
            align(bottom: camera, album)
            camera.width == (self.frame.width - 3*self.buttonSpace)/2
            album.width == camera.width
            camera.height == self.buttonSize
            album.height == self.buttonSize
        }
        
        constrain(cameraView) { view in
            view.width   == view.superview!.width
            view.height   == view.superview!.height
            view.top == view.superview!.top
            view.left == view.superview!.left
        }
        
        constrain(albumView) { view in
            view.width   == view.superview!.width
            view.height   == view.superview!.height
            view.top == view.superview!.top
            view.left == view.superview!.left
        }
        
        switchView(cameraButton)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("This class does not not support NSCoding")
    }
}


extension CKImagePickerView: CKImagePickerViewDelegate {
    func switchView(button: UIButton) {
        if button.tag == CKImagePickerConfiguration.MenuMode.Camera.rawValue {
            albumView.hidden = true
            cameraView.hidden = false
        } else {
            albumView.hidden = false
            cameraView.hidden = true
        }
    }
}

