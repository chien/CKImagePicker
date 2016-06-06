//
//  CKAlbumView.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/5/16.
//
//

import UIKit
import Cartography
import FontAwesome_swift

class CKAlbumView: CKImagePickerBaseView, UIGestureRecognizerDelegate {
    var collectionView: UICollectionView?
    var imageCropView =  CKImageCropView()
    var imageCropViewContainer = UIView()
    var deleteButton = UIButton(type: UIButtonType.System)
    
    var previousPreheatRect: CGRect = CGRectZero
    
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
    var images: [UIImage] = []
    var imageUrls: [NSURL] = []
    var currentSelectedIndex: NSIndexPath!
    
    init(configuration: CKImagePickerConfiguration) {
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

        configureCameraButton(deleteButton, title: String.fontAwesomeIconWithName(.TrashO), selector: #selector(CKAlbumView.deleteButtonPressed(_:)))
        imageCropViewContainer.addSubview(deleteButton)
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
        
        constrain(imageCropView, deleteButton) { view, button in
            view.size == view.superview!.size
            view.top == view.superview!.top
            view.left == view.superview!.left
            
            button.width == configuration.cameraControlButtonSize
            button.height == configuration.cameraControlButtonSize
            button.bottom == button.superview!.bottom + configuration.menuButtonSpacing
            button.centerX == button.superview!.centerX
        }
        
        dragDirection = Direction.Up

        imageCropViewContainer.layer.shadowColor   = UIColor.blackColor().CGColor
        imageCropViewContainer.layer.shadowRadius  = 30.0
        imageCropViewContainer.layer.shadowOpacity = 0.9
        imageCropViewContainer.layer.shadowOffset  = CGSizeZero
        reloadImages()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
    
    func reloadImages() {
        do {
            let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let imageFolderUrl = documentsUrl.URLByAppendingPathComponent(configuration.imageFolderName, isDirectory: true)
            let imageUrls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(imageFolderUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())

            self.imageUrls = imageUrls.filter{ $0.pathExtension! == "jpg" }
            self.images = self.imageUrls
                .flatMap { NSData(contentsOfURL: $0) }
                .flatMap { UIImage(data: $0) }
        } catch {
            print("error loading images")
        }

        collectionView!.reloadData()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func deleteButtonPressed(button: UIButton) {
        let cell = collectionView!.cellForItemAtIndexPath(currentSelectedIndex) as! CKAlbumViewCell
        cell.currentSelected = false

        let imageUrl = self.imageUrls[currentSelectedIndex.row]        
        let fileManager = NSFileManager.defaultManager()
        do {
            try fileManager.removeItemAtURL(imageUrl)
            currentSelectedIndex = nil
            self.imageCropView.image = nil
            reloadImages()
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
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
    
    // MARK: - ScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView == collectionView {
            self.updateCachedAssets()
        }
    }
}

extension CKAlbumView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CKAlbumViewCell", forIndexPath: indexPath) as! CKAlbumViewCell

        let currentTag = cell.tag + 1
        cell.tag = currentTag
        cell.configuration = self.configuration
        cell.image = self.images[indexPath.row]
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CKAlbumViewCell
        cell.currentSelected = true

        if currentSelectedIndex != nil {
            let currentSelectedCell = collectionView.cellForItemAtIndexPath(currentSelectedIndex) as! CKAlbumViewCell
            currentSelectedCell.currentSelected = false
        }
        currentSelectedIndex = indexPath

        self.changeImage(self.images[currentSelectedIndex.row])
        self.imageCropView.changeScrollable(true)
        
        //        imageCropViewConstraintTop.constant = imageCropViewOriginalConstraintTop
        //        collectionViewConstraintHeight.constant = self.frame.height - imageCropViewOriginalConstraintTop - imageCropViewContainer.frame.height
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            
            self.layoutIfNeeded()
            
            }, completion: nil)
        
        self.dragDirection = Direction.Up
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
}


internal extension UICollectionView {
    
    func aapl_indexPathsForElementsInRect(rect: CGRect) -> [NSIndexPath] {
        let allLayoutAttributes = self.collectionViewLayout.layoutAttributesForElementsInRect(rect)
        if (allLayoutAttributes?.count ?? 0) == 0 {return []}
        var indexPaths: [NSIndexPath] = []
        indexPaths.reserveCapacity(allLayoutAttributes!.count)
        for layoutAttributes in allLayoutAttributes! {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
        return indexPaths
    }
}

internal extension NSIndexSet {
    
    func aapl_indexPathsFromIndexesWithSection(section: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        indexPaths.reserveCapacity(self.count)
        self.enumerateIndexesUsingBlock {idx, stop in
            indexPaths.append(NSIndexPath(forItem: idx, inSection: section))
        }
        return indexPaths
    }
}

private extension CKAlbumView {
    
    func changeImage(image: UIImage) {
        self.imageCropView.image = nil
        self.imageCropView.imageSize = configuration.collectionViewCellSize
        self.imageCropView.image = image
        self.deleteButton.hidden = false
    }
    
    // MARK: - Asset Caching
    
    func resetCachedAssets() {
        previousPreheatRect = CGRectZero
    }
    
    func updateCachedAssets() {
        
        var preheatRect = self.collectionView!.bounds
        preheatRect = CGRectInset(preheatRect, 0.0, -0.5 * CGRectGetHeight(preheatRect))
        
        let delta = abs(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect))
        if delta > CGRectGetHeight(self.collectionView!.bounds) / 3.0 {
            
            var addedIndexPaths: [NSIndexPath] = []
            var removedIndexPaths: [NSIndexPath] = []
            
            self.computeDifferenceBetweenRect(self.previousPreheatRect, andRect: preheatRect, removedHandler: {removedRect in
                let indexPaths = self.collectionView!.aapl_indexPathsForElementsInRect(removedRect)
                removedIndexPaths += indexPaths
                }, addedHandler: {addedRect in
                    let indexPaths = self.collectionView!.aapl_indexPathsForElementsInRect(addedRect)
                    addedIndexPaths += indexPaths
            })
            
            let assetsToStartCaching = self.assetsAtIndexPaths(addedIndexPaths)
            let assetsToStopCaching = self.assetsAtIndexPaths(removedIndexPaths)
            
            self.previousPreheatRect = preheatRect
        }
    }
    
    func computeDifferenceBetweenRect(oldRect: CGRect, andRect newRect: CGRect, removedHandler: CGRect->Void, addedHandler: CGRect->Void) {
        if CGRectIntersectsRect(newRect, oldRect) {
            let oldMaxY = CGRectGetMaxY(oldRect)
            let oldMinY = CGRectGetMinY(oldRect)
            let newMaxY = CGRectGetMaxY(newRect)
            let newMinY = CGRectGetMinY(newRect)
            if newMaxY > oldMaxY {
                let rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY))
                addedHandler(rectToAdd)
            }
            if oldMinY > newMinY {
                let rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            if newMaxY < oldMaxY {
                let rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            if oldMinY < newMinY {
                let rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(newRect)
            removedHandler(oldRect)
        }
    }
    
    func assetsAtIndexPaths(indexPaths: [NSIndexPath]) -> [UIImage] {
        if indexPaths.count == 0 { return [] }
        
        var assets: [UIImage] = []
        assets.reserveCapacity(indexPaths.count)
        for indexPath in indexPaths {
            let asset = self.images[indexPath.item]
            assets.append(asset)
        }
        return assets
    }
}
