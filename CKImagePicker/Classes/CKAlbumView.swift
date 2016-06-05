//
//  CKAlbumView.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/5/16.
//
//

import UIKit
import Cartography

class CKAlbumView: UIView, UIGestureRecognizerDelegate {
    var configuration: CKImagePickerConfiguration!

    var collectionView: UICollectionView?
    var imageCropView =  CKImageCropView()
    var imageCropViewContainer = UIView()
    
    var previousPreheatRect: CGRect = CGRectZero
    let cellSize = CGSize(width: 100, height: 100)
    
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
    
    init(configuration: CKImagePickerConfiguration) {
        self.configuration = configuration
        super.init(frame: CGRectZero)
        self.translatesAutoresizingMaskIntoConstraints = false
        imageCropViewContainer.backgroundColor = UIColor.orangeColor()
        
        // initialize collection view
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = cellSize
        flowLayout.scrollDirection = .Vertical
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView!.registerClass(CKAlbumViewCell.self, forCellWithReuseIdentifier: "CKAlbumViewCell")
        collectionView!.translatesAutoresizingMaskIntoConstraints = false

        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.backgroundColor = UIColor.greenColor()

        let panGesture      = UIPanGestureRecognizer(target: self, action: #selector(CKAlbumView.panned(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
        
        self.addSubview(collectionView!)
        self.addSubview(imageCropViewContainer)
        imageCropViewContainer.addSubview(imageCropView)

        constrain(imageCropViewContainer, collectionView!) { v1, v2 in
            v1.top == v1.superview!.top
            v1.left == v1.superview!.left
            v1.width == v1.superview!.width
            v1.height == v1.superview!.width

            v2.height == CGFloat(200)
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

        if images.count > 0 {
            reloadImages()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
    }
    
    func reloadImages() {
        collectionView!.reloadData()
        collectionView!.selectItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.None)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
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
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.changeImage(self.images[indexPath.row])
        
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
        self.imageCropView.imageSize = CGSize(width: 100, height: 100)
        self.imageCropView.image = image
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
