//
//  CKImageCropView.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/3/16.
//
//

import UIKit

final class CKImageCropView: UIScrollView, UIScrollViewDelegate {
    
    var imageView = UIImageView()
    
    var imageSize: CGSize! {
        didSet {
            
            if imageSize.width < self.frame.width || imageSize.height < self.frame.height {
                
                // The width or height of the image is smaller than the frame size
                
                if imageSize.width > imageSize.height {
                    
                    // Width > Height
                    
                    let ratio = self.frame.width / imageSize.width
                    
                    imageView.frame = CGRect(
                        origin: CGPointZero,
                        size: CGSize(width: self.frame.width, height: imageSize.height * ratio)
                    )
                    
                } else {
                    
                    // Width <= Height
                    
                    let ratio = self.frame.height / imageSize.height
                    
                    imageView.frame = CGRect(
                        origin: CGPointZero,
                        size: CGSize(width: imageSize.width * ratio, height: self.frame.size.height)
                    )
                    
                }
                
                imageView.center = self.center
                
            } else {
                
                // The width or height of the image is bigger than the frame size
                
                if imageSize.width > imageSize.height {
                    
                    // Width > Height
                    
                    let ratio = self.frame.height / imageSize.height
                    
                    imageView.frame = CGRect(
                        origin: CGPointZero,
                        size: CGSize(width: imageSize.width * ratio, height: self.frame.height)
                    )
                    
                } else {
                    
                    // Width <= Height
                    
                    let ratio = self.frame.width / imageSize.width
                    
                    imageView.frame = CGRect(
                        origin: CGPointZero,
                        size: CGSize(width: self.frame.width, height: imageSize.height * ratio)
                    )
                    
                }
                
                self.contentOffset = CGPoint(
                    x: imageView.center.x - self.center.x,
                    y: imageView.center.y - self.center.y
                )
            }
            
            self.contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)
            
            self.zoomScale = 1.0
        }
    }
    
    var image: UIImage! = nil {
        
        didSet {
            
            if image != nil {
                
                if !imageView.isDescendantOfView(self) {
                    self.imageView.alpha = 1.0
                    self.addSubview(imageView)
                }
                
            } else {
                
                imageView.image = nil
                return
            }

            imageView.image = image
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: CGRectZero)
        self.frame.size      = CGSizeZero
        self.clipsToBounds   = true
        self.imageView.alpha = 1.0
        self.addSubview(imageView)
        
        imageView.frame = CGRect(origin: CGPointZero, size: CGSizeZero)
        
        self.maximumZoomScale = 2.0
        self.minimumZoomScale = 0.8
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator   = false
        self.bouncesZoom = true
        self.bounces = true
        self.delegate = self
    }
    
    
    func changeScrollable(isScrollable: Bool) {
        
        self.scrollEnabled = isScrollable
    }
    
    // MARK: UIScrollViewDelegate Protocol
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return imageView
        
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
            
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
        
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        
        self.contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)
    }
    
}
