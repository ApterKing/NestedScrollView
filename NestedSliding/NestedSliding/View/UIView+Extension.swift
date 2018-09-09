//
//  UIView+Extension.swift
//  NestedSliding
//
//  Created by wangcong on 2018/9/7.
//  Copyright © 2018年 wangcong. All rights reserved.
//

import UIKit

extension UIView {
    
    var left: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            var rect = frame
            rect.origin.x = newValue
            frame = rect
        }
    }
    
    var right: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set {
            var rect = frame
            rect.origin.x = newValue - rect.size.width
            frame = rect
        }
    }
    
    var top: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            var rect = frame
            rect.origin.y = newValue
            frame = rect
        }
    }
    
    var bottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set {
            var rect = frame
            rect.origin.y = newValue - frame.size.height
            frame = rect
        }
    }
    
    var width: CGFloat {
        get {
            return frame.size.width
        }
        set {
            var rect = frame
            rect.size.width = newValue
            frame = rect
        }
    }
    
    var height: CGFloat {
        get {
            return frame.size.height
        }
        set {
            var rect = frame
            rect.size.height = newValue
            frame = rect
        }
    }
    
    public var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    public var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
}
