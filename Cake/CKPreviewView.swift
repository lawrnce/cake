//
//  CKPreviewView.swift
//  Cake
//
//  Created by musashi on 12/25/15.
//  Copyright © 2015 Cake. All rights reserved.
//

import UIKit
import GLKit
import AVFoundation

class CKPreviewView: GLKView, ImageTarget {
    
    var filter: CIFilter!
    var coreImageContext: CIContext!
    var drawableBounds: CGRect!
    
    override init(frame: CGRect, context: EAGLContext) {
        super.init(frame: frame, context: context)
        
        self.enableSetNeedsDisplay = false
        self.backgroundColor = UIColor.blackColor()
        self.opaque = true
        
        self.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        self.frame = frame
        
        self.bindDrawable()
        self.drawableBounds = self.bounds
        self.drawableBounds.size.width = CGFloat(self.drawableWidth)
        self.drawableBounds.size.height = CGFloat(self.drawableHeight)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("filterChanged:"), name: FILTER_CHANGED, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func filterChanged(notification: NSNotification) {
        self.filter = notification.object as! CIFilter
    }
    
    func setImage(sourceImage: CIImage) {
        self.bindDrawable()
//        self.filter.setValue(sourceImage, forKey: kCIInputImageKey)
        
//        let filteredImage: CIImage? = self.filter.outputImage
        
        let filteredImage = sourceImage
        
//        if filteredImage != nil {
            let cropRect = CenterCropImageRect(sourceImage.extent, previewRect: self.drawableBounds)
            self.coreImageContext.drawImage(filteredImage, inRect: self.drawableBounds, fromRect: cropRect)
//        }
        
        self.display()
//        self.filter.setValue(nil, forKey: kCIInputImageKey)
        
    }

}

func CenterCropImageRect(sourceRect: CGRect, previewRect: CGRect) -> CGRect {
    let sourceAspectRatio: CGFloat = sourceRect.size.width / sourceRect.size.height
    let previewAspectRatio: CGFloat = previewRect.size.width  / previewRect.size.height
    
    var drawRect = sourceRect
    
    if (sourceAspectRatio > previewAspectRatio) {
        let scaledHeight = drawRect.size.height * previewAspectRatio
        drawRect.origin.x += (drawRect.size.width - scaledHeight) / 2.0
        drawRect.size.width = scaledHeight
    } else {
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspectRatio) / 2.0
        drawRect.size.height = drawRect.size.width / previewAspectRatio
    }
    
    return drawRect
}


class CKContextManager: NSObject {
    
    static let sharedInstance = CKContextManager()
    
    var eaglContext: EAGLContext!
    var ciContext: CIContext!
    
    override init() {
        super.init()
        self.eaglContext = EAGLContext(API: .OpenGLES2)
        let options: [String : AnyObject] = [kCIContextWorkingColorSpace: NSNull()]
        self.ciContext = CIContext(EAGLContext: self.eaglContext, options: options)
    }
    
}

protocol ImageTarget {
    func setImage(image: CIImage)
}