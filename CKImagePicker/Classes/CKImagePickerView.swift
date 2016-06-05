//
//  CKImagePickerView.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/3/16.
//
//

import UIKit
import Cartography

public class CKImagePickerView: UIView {
    var configuration: CKImagePickerConfiguration!
    let buttonSize = CGFloat(30.0)
    let buttonSpace = CGFloat(2.0)
    let albumView: CKAlbumView!

    // button section
    var buttonSectionView = UIView()
    var cameraButton = UIButton(type: UIButtonType.System)
    var albumButton = UIButton(type: UIButtonType.System)
    
    public init(frame: CGRect, configuration: CKImagePickerConfiguration) {
        self.configuration = configuration
        self.albumView = CKAlbumView(configuration: self.configuration)
        super.init(frame: frame)

        let buttonSectionHeight = buttonSize+2*buttonSpace
        self.addSubview(albumView)

        // Button Section
        self.addSubview(buttonSectionView)
        buttonSectionView.backgroundColor = UIColor.blueColor()
        buttonSectionView.addSubview(cameraButton)
        buttonSectionView.addSubview(albumButton)
        
        cameraButton.backgroundColor = configuration.backgroundColor
        cameraButton.setTitle("Camera", forState: UIControlState.Normal)
        cameraButton.titleLabel!.textColor = configuration.textColor
        
        albumButton.backgroundColor = configuration.backgroundColor
        albumButton.setTitle("Album", forState: UIControlState.Normal)
        albumButton.titleLabel!.textColor = configuration.textColor

        constrain(buttonSectionView, albumView) { view1, view2 in
            view1.width   == view1.superview!.width
            view1.height   == buttonSectionHeight
            view1.top  == view2.bottom
            view1.left == view1.superview!.left
            view2.top == view2.superview!.top
            view2.left == view2.superview!.left
            view2.width == view2.superview!.width
            view2.height == view2.superview!.height - buttonSectionHeight
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
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("This class does not not support NSCoding")
    }
}

