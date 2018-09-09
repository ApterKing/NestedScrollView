//
//  HeaderView.swift
//  NestedSliding
//
//  Created by wangcong on 2018/9/7.
//  Copyright © 2018年 wangcong. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    
    static let defaultHeight: CGFloat = 240
    

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var navBar: UIView!
    
    @IBOutlet weak var heightNavBar: NSLayoutConstraint!
    
    static let instance = Bundle.main.loadNibNamed("HeaderView", owner: nil, options: nil)?.first as? HeaderView

    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.cornerRadius = 10
        heightNavBar.constant = UIScreen.naviBarHeight
    }
    
    func updateUI() {
        
        let change = HeaderView.defaultHeight - height
        let navBarDelta: CGFloat = _validRange(height: change, max: HeaderView.defaultHeight - UIScreen.naviBarHeight)
        navBar.backgroundColor = UIColor.white.withAlphaComponent(navBarDelta)
        if navBarDelta >= 0.9 {
            closeButton.setImage(UIImage(named: "close"), for: .normal)
            titleLabel.textColor = UIColor.darkText
        } else {
            closeButton.setImage(UIImage(named: "close_white"), for: .normal)
            titleLabel.textColor = UIColor.white
        }
    }
    
    private func _validRange(height: CGFloat, max: CGFloat) -> CGFloat {
        let ratio = height / max
        
        if ratio > 1 {
            return 1
        } else if ratio < 0 {
            return 0
        }
        
        return ratio
    }
}
