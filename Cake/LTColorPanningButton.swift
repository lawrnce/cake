//
//  LTColorPanningButton.swift
//  LTColorMaskedButton
//
//  Created by lola on 2/17/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit

class LTColorPanningButton: UIView {
    
    private var maskedView: LTMaskedView!
    private var button: UIButton!
    
    convenience init(frame: CGRect, withSVG name: String, withForegroundColor foregroundColor: UIColor, withBackgroundColor backgroundColor: UIColor) {
        self.init(frame: frame)
        self.maskedView = LTMaskedView(SVGname: name)
        self.maskedView.backgroundColor = backgroundColor
        self.maskedView.animatedView.backgroundColor = foregroundColor
        self.button = UIButton(frame: CGRectMake(0, 0, self.frame.width, self.frame.height))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.maskedView.center = CGPointMake(self.frame.width / 2.0, self.frame.height / 2.0)
        self.addSubview(self.maskedView)
        self.addSubview(self.button)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMaskWithSVGName(name: String) {
        let backgroundColor = self.maskedView.backgroundColor
        let foregroundColor = self.maskedView.animatedView.backgroundColor
        self.maskedView.removeFromSuperview()
        self.maskedView = LTMaskedView(SVGname: name)
        self.maskedView.backgroundColor = backgroundColor
        self.maskedView.animatedView.backgroundColor = foregroundColor
        layoutSubviews()
    }
    
    func change(foregroundColor: UIColor, andBackgroundColor backgroundColor: UIColor) {
        self.maskedView.backgroundColor = backgroundColor
        self.maskedView.animatedView.backgroundColor = foregroundColor
    }
    
    func addTarget(target: AnyObject?, action selector: Selector, forControlEvents event: UIControlEvents) {
        self.button.addTarget(target, action: selector, forControlEvents: event)
    }
    
    func resetColor(){
        self.maskedView.revertAnimatingView()
    }
    
    func updateColorOffest(targetOffset: CGFloat) {
        
        let normalizedOffest = targetOffset - self.frame.origin.x
        self.maskedView.setFillOffset(normalizedOffest)
        
    }
}
