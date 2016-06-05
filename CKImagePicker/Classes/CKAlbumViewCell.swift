//
//  CKAlbumViewCell.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/5/16.
//
//

import UIKit

final class CKAlbumViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
    
    override var selected : Bool {
        didSet {
            self.layer.borderColor = UIColor.yellowColor().CGColor
            self.layer.borderWidth = selected ? 2 : 0
        }
    }
}