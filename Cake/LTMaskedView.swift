//
//  LTMaskedView.swift
//  LTColorMaskedButton
//
//  Created by lola on 2/17/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit

class LTMaskedView: UIView {
    
    var animatedView: UIView!
    var layerMask: CAShapeLayer!
    
    private var size: CGSize!
    
    convenience init(SVGname: String) {
        
        // Set path for shape layer
        let path = PocketSVG.pathFromSVGFileNamed(SVGname).takeUnretainedValue()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        
        // Get bounding box and center
        let boudningBox = CGPathGetBoundingBox(shapeLayer.path)
        shapeLayer.bounds = boudningBox
        shapeLayer.position = CGPointMake(boudningBox.size.width * 0.5, boudningBox.size.height * 0.5)
        let size = boudningBox.size
        
        // set frame to size of shape bounding box
        self.init(frame: CGRectMake(0, 0, size.width, size.height))
        self.layerMask = shapeLayer
        self.animatedView = UIView(frame: CGRectMake(0, 0, self.frame.width + kTimerIncrementWidth*2.0, self.frame.height))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(self.animatedView)
        self.layer.mask = self.layerMask
    }
    
    func revertAnimatingView() {
        self.animatedView.frame = CGRectMake(0, 0, self.frame.width + kTimerIncrementWidth*2.0, self.frame.height)
        setNeedsLayout()
    }
    
    func setFillOffset(targetOffset: CGFloat) {

        let normalizedOffest = targetOffset - self.frame.origin.x
        
        if normalizedOffest >= -kTimerIncrementWidth && normalizedOffest <= self.frame.width + kTimerIncrementWidth {
            self.animatedView.frame.origin.x = normalizedOffest
            setNeedsLayout()
        }
    }
}
