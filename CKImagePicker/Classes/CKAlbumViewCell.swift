//
//  CKAlbumViewCell.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/5/16.
//
//

import UIKit
import Cartography

class CKAlbumViewCell: UICollectionViewCell {
    var configuration: CKImagePickerConfiguration! {
        didSet {
            self.layer.borderColor = (selected ? configuration.tintColor : UIColor.clearColor()).CGColor
        }
    }

    var imageView = UIImageView()
    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
    
    override var selected : Bool {
        didSet {
            self.layer.borderWidth = selected ? 2 : 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selected = false
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(imageView)
        constrain(self.imageView) { view in
            view.size == view.superview!.size
            view.top == view.superview!.top
            view.left == view.superview!.left
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not not support NSCoding")
    }
}