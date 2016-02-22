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
    var buffers: [UnsafeMutablePointer<CMSampleBuffer?>]!
    var processed: [CGImage]!
    
    override init() {
        super.init()
        self.processed = [CGImage]()
        self.buffers = [UnsafeMutablePointer<CMSampleBuffer?>]()
    }
    
    func appendBuffer(buffer: UnsafeMutablePointer<CMSampleBuffer?>, mirrored: Bool) {
        self.buffers.append(buffer)
        let ciimage = self.getCroppedPreviewImageFromBuffer(buffer.memory!, mirrored: mirrored)
        buffer.destroy()
        self.processed.append(self.getDownscaleImage(ciimage)!)
        self.frameCount++
    }
    
    private func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, fromRect: inputImage.extent)
    }
    
    private func getCroppedPreviewImageFromBuffer(buffer: CMSampleBuffer, mirrored: Bool) -> CIImage {
        let imageBuffer: CVPixelBufferRef = CMSampleBufferGetImageBuffer(buffer)!
        let sourceImage: CIImage = CIImage(CVPixelBuffer: imageBuffer).copy() as! CIImage
        let croppedSourceImage = sourceImage.imageByCroppingToRect(CGRectMake(0, 0, 720, 720))
        
        if mirrored {
            let transform: CGAffineTransform!
            transform = CGAffineTransformMakeScale(-1.0, 1.0)
            return croppedSourceImage.imageByApplyingTransform(transform)
        } else {
            return croppedSourceImage
        }
    }

    func getBitmaps() -> [CGImage] {
        return self.processed
    }
    
    private func getDownscaleImage(sourceImage: CIImage) -> CGImage? {
        let filteredImage = sourceImage.imageByApplyingFilter("CIUnsharpMask", withInputParameters: ["inputImage" : sourceImage])
        let frame: CGImage = CKContextManager.sharedInstance.ciContext.createCGImage(filteredImage, fromRect: filteredImage.extent)
        let width = 360
        let height = 360
        let bitsPerComponent = CGImageGetBitsPerComponent(frame)
        let bytesPerRow = CGImageGetBytesPerRow(frame)
        let colorSpace = CGImageGetColorSpace(frame)
        let bitmapInfo = CGImageGetBitmapInfo(frame)
        let context = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        CGContextSetInterpolationQuality(context, .High)
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: CGSize(width: CGFloat(width), height: CGFloat(height))), frame)
        if let scaledFrame = CGBitmapContextCreateImage(context) {
            return scaledFrame
        } else {
            return nil
        }
    }
}

protocol CKGifWriterDelegate {
    
}

