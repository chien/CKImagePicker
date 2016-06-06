//
//  CKImagePickerView.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/3/16.
//
//

import UIKit
import Cartography

protocol CKImagePickerViewDelegate: CKCameraViewDelegate {
    func switchView(button: UIButton)
}

public class CKImagePickerView: UIView {
    var configuration: CKImagePickerConfiguration!

    let albumView: CKAlbumView!
    let cameraView: CKCameraView!
    let contentContainer = UIView()

    // button section
    var buttonSectionView = UIView()
    var cameraButton = UIButton(type: UIButtonType.System)
    var albumButton = UIButton(type: UIButtonType.System)
    
    var delegate: CKImagePickerViewDelegate!
    
    public init(frame: CGRect, configuration: CKImagePickerConfiguration) {
        self.configuration = configuration
        self.albumView = CKAlbumView(configuration: self.configuration)
        self.cameraView = CKCameraView(configuration: self.configuration)
        super.init(frame: frame)
        self.frame = frame
        
        self.addSubview(contentContainer)
        contentContainer.addSubview(albumView)
        contentContainer.addSubview(cameraView)
        contentContainer.backgroundColor = UIColor.whiteColor()

        // Button Section
        self.addSubview(buttonSectionView)
        buttonSectionView.addSubview(cameraButton)
        buttonSectionView.addSubview(albumButton)

        cameraButton.setTitle("Camera", forState: UIControlState.Normal)
        cameraButton.tag = CKImagePickerConfiguration.MenuMode.Camera.rawValue
        cameraButton.titleLabel!.font = configuration.font

        albumButton.setTitle("Album", forState: UIControlState.Normal)
        albumButton.tag = CKImagePickerConfiguration.MenuMode.Album.rawValue
        albumButton.titleLabel!.font = configuration.font

        constrain(buttonSectionView, contentContainer) { view1, view2 in
            view2.top == view2.superview!.top
            view2.left == view2.superview!.left
            view2.width == view2.superview!.width
            view2.height == view2.superview!.height - configuration.menuSectionHeight

            view1.top  == view2.bottom
            view1.left == view1.superview!.left
            view1.height == configuration.menuSectionHeight
            view1.width == view1.superview!.width
        }
        
        constrain(cameraButton, albumButton) { camera, album in
            camera.bottom == camera.superview!.bottom - self.configuration.menuButtonSpacing
            camera.left == camera.superview!.left + self.configuration.menuButtonSpacing
            album.left == camera.right + self.configuration.menuButtonSpacing
            align(bottom: camera, album)
            camera.width == (self.frame.width - 3*self.configuration.menuButtonSpacing)/2
            album.width == camera.width
            camera.height == self.configuration.menuButtonSize
            album.height == self.configuration.menuButtonSize
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
        resetButton()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("This class does not not support NSCoding")
    }
}

internal extension CKImagePickerView {
    func cameraButtonPressed() {
        resetButton()
        cameraButton.tintColor = self.configuration.tintColor
        albumView.hidden = true
        cameraView.hidden = false
    }
    
    func albumButtonPressed() {
        resetButton()
        albumButton.tintColor = self.configuration.tintColor
        albumView.hidden = false
        cameraView.hidden = true
        albumView.setDefaultImage()
    }
    
    private func resetButton() {
        albumButton.tintColor = self.configuration.textColor
        albumButton.backgroundColor = self.configuration.backgroundColor
        cameraButton.tintColor = self.configuration.textColor
        cameraButton.backgroundColor = self.configuration.backgroundColor
    }
}
