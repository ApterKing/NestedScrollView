//
//  OtherView.swift
//  NestedSliding
//
//  Created by wangcong on 2018/9/9.
//  Copyright © 2018年 wangcong. All rights reserved.
//

import UIKit

class OtherView: UIView {
    
    static let defaultHeight: CGFloat = 90

    @IBOutlet weak var scrollView: UIScrollView!
    
    static let instance = Bundle.main.loadNibNamed("OtherView", owner: nil, options: nil)?.first as? OtherView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.contentSize = CGSize(width: 800, height: OtherView.defaultHeight)
    }
}
