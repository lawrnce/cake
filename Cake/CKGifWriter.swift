//
//  CKGifWriter.swift
//  Cake
//
//  Created by lola on 2/20/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import AVFoundation

class CKGifWriter: NSObject {
    
    var frameCount = 0
    var bitmaps: [CGImage]!
    
    override init() {
        super.init()
        self.bitmaps = [CGImage]()
    }
    
    func appendFrame(frameData: CIImage) {
        let cgImage = convertCIImageToCGImage(frameData)
        self.bitmaps.append(cgImage)
        self.frameCount++
    }
    
    private func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, fromRect: inputImage.extent)
    }
    
//    private func getDownscaleImageMirrored(sourceImage: CIImage) -> CGImage? {
//        let filteredImage = sourceImage.imageByApplyingFilter("CIUnsharpMask", withInputParameters: ["inputImage" : sourceImage])
//        let frame: CGImage = CKContextManager.sharedInstance.ciContext.createCGImage(filteredImage, fromRect: filteredImage.extent)
//        let width = 360
//        let height = 360
//        let bitsPerComponent = CGImageGetBitsPerComponent(frame)
//        let bytesPerRow = CGImageGetBytesPerRow(frame)
//        let colorSpace = CGImageGetColorSpace(frame)
//        let bitmapInfo = CGImageGetBitmapInfo(frame)
//        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
//        CGContextSetInterpolationQuality(context, .High)
//        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), frame)
//        
//        if let scaledFrame = CGBitmapContextCreateImage(context) {
//            return scaledFrame
//        } else {
//            return nil
//        }
//    }
}
