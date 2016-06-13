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

    override var selected: Bool {
        get {
            return super.selected
        }
        set {
            if newValue {
                super.selected = true
                self.layer.borderWidth = 2
                self.layer.borderColor = configuration!.tintColor.CGColor
            } else if newValue == false {
                super.selected = false
                self.layer.borderWidth = 0
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selected = false
        self.translatesAutoresizingMaskIntoConstraints = false

        imageView = UIImageView(frame: self.contentView.bounds)
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFill
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.contentView.addSubview(imageView)
        self.setNeedsDisplay()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not not support NSCoding")
    }
}