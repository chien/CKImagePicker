//
//  CKImagePickerConfiguration.swift
//  Pods
//
//  Created by Cheng-chien Kuo on 6/5/16.
//
//

extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, 0.0)!  }
}

public class CKImagePickerConfiguration {
    public var font = UIFont.systemFontOfSize(16)
    public var textColor = UIColor.lightGrayColor()
    public var backgroundColor = UIColor.whiteColor()
    public var utilButtonBackgroundColor = UIColor.clearColor()
    public var tintColor = UIColor.orangeColor()
    
    public var menuButtonSize = CGFloat(30)
    public var menuButtonSpacing = CGFloat(2)

    public var imageFolderName = "default"
    
    public var cameraControlButtonSize = CGFloat(60)
    public var utilControlButtonSize = CGFloat(40)
    public var paddingSize = CGFloat(10)
    
    public var collectionViewImagePerRow = CGFloat(5)
    public var collectionViewLineSpacing = CGFloat(2)
    public var collectionViewCellSize: CGSize {
        let cellSize = (imageContainerSize-((collectionViewImagePerRow-1)*collectionViewLineSpacing))/CGFloat(collectionViewImagePerRow)
        return CGSize(width: cellSize, height: cellSize)
    }
    public var compressionRate = CGFloat(0.5)

    internal var menuSectionHeight: CGFloat {
        return menuButtonSize + 2*menuButtonSpacing
    }
    
    lazy internal var imageContainerSize: CGFloat = {
        return self.frame.width
    }()
    
    lazy internal var controllerContainerHeight: CGFloat = {
        return self.frame.height - self.imageContainerSize - self.menuSectionHeight
    }()
    
    internal let frame: CGRect!
    
    public enum MenuMode: Int {
        case Camera
        case Album
    }
    
    public init(frame: CGRect) {
        self.frame = frame
    }
}
