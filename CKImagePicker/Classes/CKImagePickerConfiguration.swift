//
//  CKImagePickerConfiguration.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/5/16.
//
//

public class CKImagePickerConfiguration {
    public var font = UIFont.systemFontOfSize(16)
    public var textColor = UIColor.lightGrayColor()
    public var backgroundColor = UIColor.whiteColor()
    public var tintColor = UIColor.orangeColor()
    
    public var menuButtonSize = CGFloat(30)
    public var menuButtonSpacing = CGFloat(2)

    public var imageFolderName = "default"
    
    public var collectionViewImagePerRow = CGFloat(4)
    public var collectionViewLineSpacing = CGFloat(2)
    public var collectionViewCellSize: CGSize {
        let cellSize = (imageContainerSize-((collectionViewImagePerRow-1)*collectionViewLineSpacing))/CGFloat(collectionViewImagePerRow)
        return CGSize(width: cellSize, height: cellSize)
    }
    
    internal var menuSectionHeight: CGFloat {
        return menuButtonSize + 2*menuButtonSpacing
    }
    
    internal var imageContainerSize: CGFloat {
        return frame.width
    }
    
    internal var controllerContainerHeight: CGFloat {
        return frame.height - imageContainerSize - menuSectionHeight
    }
    
    private let frame: CGRect!
    
    public enum MenuMode: Int {
        case Camera
        case Album
    }
    
    public init(frame: CGRect) {
        self.frame = frame
    }
}
