//
//  CKAlbumView.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/5/16.
//
//

import Foundation
import UIKit
import Cartography
import FontAwesome_swift
import Haneke

@objc protocol CKAlbumViewDelegate: class {
    func imageDeleted()
    func deleteButtonPressed(button: UIButton)
}

public class CKAlbumView: CKImagePickerBaseView, UIGestureRecognizerDelegate {
    var collectionView: UICollectionView?
    var imageCropView =  CKImageCropView()
    var imageCropViewContainer = UIView()
    var deleteButton = UIButton(type: UIButtonType.System)
    
    var previousPreheatRect: CGRect = CGRectZero
    
    var delegate: CKAlbumViewDelegate? = nil
    
    // Variables for calculating the position
    enum Direction {
        case Scroll
        case Stop
        case Up
        case Down
    }
    let imageCropViewOriginalConstraintTop: CGFloat = 0
    let imageCropViewMinimalVisibleHeight: CGFloat  = 100
    var dragDirection = Direction.Up
    var imaginaryCollectionViewOffsetStartPosY: CGFloat = 0.0
    
    var cropBottomY: CGFloat  = 0.0
    var dragStartPos: CGPoint = CGPointZero
    let dragDiff: CGFloat     = 20.0
    var imageUrls: [NSURL] = []
    var currentSelectedRow = 0
    
    public init(configuration: CKImagePickerConfiguration) {
        super.init(frame: CGRectZero)
        self.configuration = configuration
        self.translatesAutoresizingMaskIntoConstraints = false
        imageCropViewContainer.backgroundColor = self.configuration.backgroundColor

        // initialize collection view
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = configuration.collectionViewCellSize
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumLineSpacing = configuration.collectionViewLineSpacing
        flowLayout.minimumInteritemSpacing = configuration.collectionViewLineSpacing

        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView!.registerClass(CKAlbumViewCell.self, forCellWithReuseIdentifier: "CKAlbumViewCell")
        collectionView!.translatesAutoresizingMaskIntoConstraints = false

        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.backgroundColor = self.configuration.backgroundColor

        let panGesture      = UIPanGestureRecognizer(target: self, action: #selector(CKAlbumView.panned(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        
        self.addSubview(collectionView!)
        self.addSubview(imageCropViewContainer)
        imageCropViewContainer.addSubview(imageCropView)
        imageCropViewContainer.addSubview(deleteButton)

        configureUtilButton(deleteButton, title: String.fontAwesomeIconWithName(.TrashO), selector: #selector(CKAlbumView.deleteButtonPressed(_:)))
        deleteButton.hidden = true

        constrain(imageCropViewContainer, collectionView!) { v1, v2 in
            v1.top == v1.superview!.top
            v1.left == v1.superview!.left
            v1.width == configuration.imageContainerSize
            v1.height == configuration.imageContainerSize

            v2.height == configuration.controllerContainerHeight
            v2.width == v2.superview!.width
            v2.top == v1.bottom
            v2.left == v1.left
        }
        
        constrain(imageCropView) { view in
            view.size == view.superview!.size
            view.top == view.superview!.top
            view.left == view.superview!.left
        }
        
        dragDirection = Direction.Up

        imageCropViewContainer.layer.shadowColor   = UIColor.blackColor().CGColor
        imageCropViewContainer.layer.shadowRadius  = 30.0
        imageCropViewContainer.layer.shadowOpacity = 0.9
        imageCropViewContainer.layer.shadowOffset  = CGSizeZero
        reloadImages()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDefaultImage() {
        if (self.imageUrls.count > 0) {
            self.changeImage(self.imageUrls[currentSelectedRow])
            self.imageCropView.changeScrollable(true)
        }
    }
    
    func resetSelectedImage() {
        self.currentSelectedRow = 0
        setDefaultImage()
    }

    class public func loadImageUrls(configuration: CKImagePickerConfiguration) -> [NSURL] {
        do {
            let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let imageFolderUrl = documentsUrl.URLByAppendingPathComponent(configuration.imageFolderName, isDirectory: true)
            let imageUrls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(imageFolderUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())

            return imageUrls
                .filter{ $0.pathExtension! == "jpg" }
                .sort{ (element1, element2) -> Bool in
                    return element1.lastPathComponent > element2.lastPathComponent
            }
        } catch {
            return []
            print("error loading image urls")
        }
    }

    func reloadImages() {
        do {
            self.imageUrls = CKAlbumView.loadImageUrls(configuration)
        } catch {
            print("error loading images")
        }

        collectionView!.reloadData()
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func panned(sender: UITapGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.Began {
            
            let view    = sender.view
            let loc     = sender.locationInView(view)
            let subview = view?.hitTest(loc, withEvent: nil)
            
//            if subview == imageCropView && imageCropViewConstraintTop.constant == imageCropViewOriginalConstraintTop {
//                
//                return
//            }
            
            dragStartPos = sender.locationInView(self)
            
            cropBottomY = self.imageCropViewContainer.frame.origin.y + self.imageCropViewContainer.frame.height
            
            // Move
//            if dragDirection == Direction.Stop {
//                
//                dragDirection = (imageCropViewConstraintTop.constant == imageCropViewOriginalConstraintTop) ? Direction.Up : Direction.Down
//            }
            
            // Scroll event of CollectionView is preferred.
            if (dragDirection == Direction.Up   && dragStartPos.y < cropBottomY + dragDiff) ||
                (dragDirection == Direction.Down && dragStartPos.y > cropBottomY) {
                
                dragDirection = Direction.Stop
                
                imageCropView.changeScrollable(false)
                
            } else {
                
                imageCropView.changeScrollable(true)
            }
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            let currentPos = sender.locationInView(self)
            
            if dragDirection == Direction.Up && currentPos.y < cropBottomY - dragDiff {
//                
//                imageCropViewConstraintTop.constant = max(imageCropViewMinimalVisibleHeight - self.imageCropViewContainer.frame.height, currentPos.y + dragDiff - imageCropViewContainer.frame.height)
//                
//                collectionViewConstraintHeight.constant = min(self.frame.height - imageCropViewMinimalVisibleHeight, self.frame.height - imageCropViewConstraintTop.constant - imageCropViewContainer.frame.height)
                
            } else if dragDirection == Direction.Down && currentPos.y > cropBottomY {
                
//                imageCropViewConstraintTop.constant = min(imageCropViewOriginalConstraintTop, currentPos.y - imageCropViewContainer.frame.height)
//                
//                collectionViewConstraintHeight.constant = max(self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height, self.frame.height - imageCropViewConstraintTop.constant - imageCropViewContainer.frame.height)
                
            } else if dragDirection == Direction.Stop && collectionView!.contentOffset.y < 0 {
                
                dragDirection = Direction.Scroll
                imaginaryCollectionViewOffsetStartPosY = currentPos.y
                
            } else if dragDirection == Direction.Scroll {
                
//                imageCropViewConstraintTop.constant = imageCropViewMinimalVisibleHeight - self.imageCropViewContainer.frame.height + currentPos.y - imaginaryCollectionViewOffsetStartPosY
//                
//                collectionViewConstraintHeight.constant = max(self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height, self.frame.height - imageCropViewConstraintTop.constant - imageCropViewContainer.frame.height)
                
            }
            
        } else {
            
            imaginaryCollectionViewOffsetStartPosY = 0.0
            
            if sender.state == UIGestureRecognizerState.Ended && dragDirection == Direction.Stop {
                
                imageCropView.changeScrollable(true)
                return
            }
            
            let currentPos = sender.locationInView(self)
            
            if currentPos.y < cropBottomY - dragDiff /* && imageCropViewConstraintTop.constant != imageCropViewOriginalConstraintTop*/ {
                
                // The largest movement
                imageCropView.changeScrollable(false)
//                
//                imageCropViewConstraintTop.constant = imageCropViewMinimalVisibleHeight - self.imageCropViewContainer.frame.height
//                
//                collectionViewConstraintHeight.constant = self.frame.height - imageCropViewMinimalVisibleHeight
                
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    
                    self.layoutIfNeeded()
                    
                    }, completion: nil)
                
                dragDirection = Direction.Down
                
            } else {
                
                // Get back to the original position
                imageCropView.changeScrollable(true)
                
//                imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
//                collectionViewConstraintHeight.constant = self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height
                
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    
                    self.layoutIfNeeded()
                    
                    }, completion: nil)
                
                dragDirection = Direction.Up
                
            }
        }
        
        
    }
}

extension CKAlbumView: UICollectionViewDataSource, UICollectionViewDelegate {
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    // MARK: - UICollectionViewDelegate Protocol
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CKAlbumViewCell", forIndexPath: indexPath) as! CKAlbumViewCell
        cell.tag = indexPath.row
        cell.configuration = self.configuration
        cell.imageView.hnk_setImageFromURL(self.imageUrls[indexPath.row])
        
        if currentSelectedRow == indexPath.row {
            cell.selected = true
        }
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) {
            let cell = selectedCell as! CKAlbumViewCell
            cell.selected = true
        }
        
        let previousIndexPath = NSIndexPath(forRow: currentSelectedRow, inSection: 0)
        if let previousCell = collectionView.cellForItemAtIndexPath(previousIndexPath) {
            let albumViewCell = previousCell as! CKAlbumViewCell
            albumViewCell.selected = false
        }
        currentSelectedRow = indexPath.row

        self.changeImage(self.imageUrls[currentSelectedRow])
        self.imageCropView.changeScrollable(true)
        
        //        imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
        //        collectionViewConstraintHeight.constant = self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {

            self.layoutIfNeeded()
            
            }, completion: nil)
        
        self.dragDirection = Direction.Up
    }
    
    func deleteImage() {
        let indexPath = NSIndexPath(forRow: currentSelectedRow, inSection: 0)
        let cell = collectionView!.cellForItemAtIndexPath(indexPath) as! CKAlbumViewCell
        cell.selected = false
        deleteButton.hidden = true
        
        let imageUrl = self.imageUrls[indexPath.row]
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtURL(imageUrl)
            self.reloadImages()
            imageCropView.imageView.image = nil
            self.resetSelectedImage()
            delegate!.imageDeleted()
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
}

private extension CKAlbumView {
    @objc func deleteButtonPressed(button: UIButton) {
        delegate!.deleteButtonPressed(button)
    }
    
    func changeImage(url: NSURL) {
        self.imageCropView.imageSize = configuration.collectionViewCellSize
        self.imageCropView.imageView.hnk_setImageFromURL(url)
        self.deleteButton.hidden = false
    }
}
