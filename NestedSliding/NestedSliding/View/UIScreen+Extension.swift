//
//  UIScreen+Extension.swift
//  NestedSliding
//
//  Created by wangcong on 2018/9/7.
//  Copyright © 2018年 wangcong. All rights reserved.
//

import UIKit

extension UIScreen {

    static var width: CGFloat {
        get {
            return UIScreen.main.bounds.size.width
        }
    }
    
    static var height: CGFloat {
        get {
            return UIScreen.main.bounds.size.height
        }
    }
    
    static var size: CGSize {
        get {
            return UIScreen.main.bounds.size
        }
    }
    
    static func isIpone4_5() -> Bool {
        return UIScreen.width == 320 ? true : false
    }
    
    static func isIpone6_7() -> Bool {
        return UIScreen.width == 375 ? true : false
    }
    
    static func isIpone6_7_Plus() -> Bool {
        return UIScreen.width == 414 ? true : false
    }
    
    static func isIphoneX() -> Bool {
        let height = UIScreen.main.bounds.size.height
        return height >= 737 && height <= 812
    }
    
    static var statusBarHeight: CGFloat {
        get {
            return isIphoneX() ? 44 : 20
        }
    }
    
    static var naviBarHeight:CGFloat {
        get {
            return isIphoneX() ? 88 : 64
        }
    }
    
    static var tabBarHeight:CGFloat {
        get {
            return isIphoneX() ? 83 : 49
        }
    }
    
    static var homeIndicatorMoreHeight:CGFloat {
        get {
            return isIphoneX() ? 34 : 0
        }
    }
    
    static var statusBarMoreHeight:CGFloat {
        get {
            return isIphoneX() ? 24 : 0
        }
    }
}
