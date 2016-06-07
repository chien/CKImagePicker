//
//  CKAlbumViewCell.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/5/16.
//
//

import UIKit
//import Cartography

class CKAlbumViewCell: UICollectionViewCell {
    var configuration: CKImagePickerConfiguration?

    var imageView: UIImageView!

    var currentSelected : Bool {
        didSet {
            self.layer.borderWidth = currentSelected ? 2 : 0
            self.layer.borderColor = (currentSelected ? configuration!.tintColor : UIColor.blackColor()).CGColor
        }
    }

    override init(frame: CGRect) {
        self.currentSelected = false
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false

        imageView = UIImageView(frame: self.contentView.bounds)
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.contentView.addSubview(imageView)
//
//        constrain(self.imageView) { view in
//            view.size == view.superview!.size
//            view.top == view.superview!.top
//            view.left == view.superview!.left
//        }
//        
        self.setNeedsDisplay()
//        self.layoutIfNeeded()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not not support NSCoding")
    }
}