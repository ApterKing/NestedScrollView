//
//  SegmentView.swift
//  NestedSliding
//
//  Created by wangcong on 2018/9/7.
//  Copyright © 2018年 wangcong. All rights reserved.
//

import UIKit

// 这里是个demo，就简单实现一下
class SegmentView: UIView {

    @IBOutlet weak var label0: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    private var labels: [UILabel] = []
    
    static let instance = Bundle.main.loadNibNamed("SegmentView", owner: nil, options: nil)?.first as? SegmentView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labels.append(label0)
        labels.append(label1)
        labels.append(label2)
        labels.append(label3)
        highlight(index: 0)
    }
    
    func highlight(index: Int) {
        for (i, label) in labels.enumerated() {
            label.textColor = i == index ? UIColor.red : UIColor.lightGray
        }
    }
    
}
