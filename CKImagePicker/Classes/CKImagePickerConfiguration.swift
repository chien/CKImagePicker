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
    public var tintColor = UIColor.blackColor()

    public var defaultPage = 0
    public var scrollEnabled = true // in case of using swipable cells, set false
    public var menuPosition: MenuPosition = .Top
    public var menuTitleHeight: CGFloat = 30
    public var menuDescriptionHeight: CGFloat = 21
    public var menuHeight: CGFloat = 50
    public var menuItemMargin: CGFloat = 20
    public var menuItemDividerImage: UIImage?
    public var animationDuration: NSTimeInterval = 0.3
    public var deceleratingRate: CGFloat = UIScrollViewDecelerationRateFast
    public var menuSelectedItemCenter = true
    public var menuItemMode = MenuItemMode.Underline(height: 3, color: UIColor.blueColor(), horizontalPadding: 0, verticalPadding: 0)
    public var lazyLoadingPage: LazyLoadingPage = .Three
    public var menuControllerSet: MenuControllerSet = .Multiple
    public var menuComponentType: MenuComponentType = .All
    internal var menuItemViewContent: MenuItemViewContent = .Text
    internal var menuItemCount = 0
    
    internal let minumumSupportedViewCount = 1
    internal let dummyMenuItemViewsSet = 3
    
    public enum MenuMode: Int {
        case Camera
        case Album
    }
    
    public enum MenuPosition {
        case Top
        case Bottom
    }
    
    public enum MenuScrollingMode {
        case ScrollEnabled
        case ScrollEnabledAndBouces
        case PagingEnabled
    }
    
    public enum MenuItemWidthMode {
        case Flexible
        case Fixed(width: CGFloat)
    }
    
    public enum MenuDisplayMode {
        case Standard(widthMode: MenuItemWidthMode, centerItem: Bool, scrollingMode: MenuScrollingMode)
        case SegmentedControl
        case Infinite(widthMode: MenuItemWidthMode, scrollingMode: MenuScrollingMode)
    }
    
    public enum MenuItemMode {
        case None
        case Underline(height: CGFloat, color: UIColor, horizontalPadding: CGFloat, verticalPadding: CGFloat)
        case RoundRect(radius: CGFloat, horizontalPadding: CGFloat, verticalPadding: CGFloat, selectedColor: UIColor)
    }
    
    public enum LazyLoadingPage {
        case One
        case Three
    }
    
    public enum MenuControllerSet {
        case Single
        case Multiple
    }
    
    public enum MenuComponentType {
        case MenuView
        case MenuController
        case All
    }
    
    public enum MenuItemViewContent {
        case Text, Image, MultilineText
    }
    
    public init() {}
}
