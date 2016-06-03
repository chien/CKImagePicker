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
    func takePhoto(sender: UIButton)
}

public class CKImagePickerView: UIView {
    let collectionView: UICollectionView?
    let imageSize = CGFloat(70.0)
    let imageItemSpacing = CGFloat(10.0)
    let imageItemRows = CGFloat(3)
    var formHeight: CGFloat?
    var collectionViewHeight: CGFloat?
    let buttonSize = CGFloat(40.0)
    let buttonSpace = CGFloat(5.0)
    let photoButtonSize = CGFloat(60.0)

    // button section
    var buttonSectionView = UIView()
    var saveButton = UIButton(type: UIButtonType.System)
    var cancelButton = UIButton(type: UIButtonType.System)
    
    // Toolbar
    var spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    var completeTaskButton = UIButton(type: UIButtonType.System)
    var manualButton = UIButton(type: UIButtonType.System)
    
    let takePhotoButton = UIButton(type: .Custom)
    
    public override init(frame: CGRect) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSizeMake(imageSize, imageSize)
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = UIEdgeInsetsMake(imageItemSpacing, imageItemSpacing, imageItemSpacing, imageItemSpacing)
        self.collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        super.init(frame: frame)
        
        let buttonSectionHeight = buttonSize+2*buttonSpace
        self.collectionViewHeight = (imageItemRows * imageSize) + ((imageItemRows+1) * imageItemSpacing)
        self.formHeight = self.frame.height - collectionViewHeight! - buttonSectionHeight
        
        collectionView!.backgroundColor = UIColor.redColor()
        self.addSubview(collectionView!)
        
        // Take photo button
        takePhotoButton.layer.masksToBounds = true
        takePhotoButton.layer.cornerRadius = 0.5 * photoButtonSize
        takePhotoButton.setTitle("Camera", forState: .Normal)
        self.addSubview(takePhotoButton)
        
        constrain( collectionView!, takePhotoButton) { v2, v3 in
            v2.width == v2.superview!.width
            v2.height == (v2.superview!.height-formHeight!-buttonSectionHeight)
            v2.top == v2.superview!.top
            
            v3.width == photoButtonSize
            v3.height == photoButtonSize
            v3.centerY == v2.centerY + photoButtonSize
            v3.right == v3.superview!.right - imageItemSpacing
        }
        
        // Product Sections Positioning
        buttonSectionView.layoutMargins = UIEdgeInsets(top: self.buttonSpace, left: self.buttonSpace, bottom: self.buttonSpace, right: self.buttonSpace)
        self.addSubview(buttonSectionView)
        
        constrain(buttonSectionView, collectionView!) { view1, view2 in
            view1.width   == view1.superview!.width
            view1.height   == buttonSectionHeight
            view1.top  == view2.bottom
            view1.left == view1.superview!.left
        }
        
        // Button Section
        self.buttonSectionView.frame = CGRectMake(0, self.bounds.maxY-buttonSectionHeight, self.bounds.size.width, buttonSectionHeight)
        self.buttonSectionView.backgroundColor = .whiteColor()
        self.addSubview(buttonSectionView)

        buttonSectionView.addSubview(cancelButton)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("This class does not not support NSCoding")
    }
}

