//
//  CKEffectsTableView.swift
//  Cake
//
//  Created by lola on 2/19/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit

class CKDashedBorder: UIView {

    private var border: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDashedBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDashedBorder()
    }
    
    private func setupDashedBorder() {
        self.border = CAShapeLayer()
        self.border.strokeColor = kLightTint.CGColor
        self.border.fillColor = nil
        self.border.lineDashPattern = [4,2]
        self.layer.addSublayer(border)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.border.path = UIBezierPath(rect: self.bounds).CGPath
        self.border.frame = self.bounds
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
