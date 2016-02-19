//
//  CKPreviewViewController.swift
//  Cake
//
//  Created by lola on 2/18/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

class CKPreviewViewController: UIViewController {

    var duration: Double!
    var bitmaps: [CGImage]!
    var frames: [[UIImage?]]!
    
    private var editViewController: CKEditViewController!
    
    private var renderedFrames: [UIImage]!
    private var animatedImageView: UIImageView!
    private var editButton: UIButton!
    private var cancelButton: UIButton!
    private var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        processBitmaps()
        setupAnimatedImageView()
        setupEditButton()
        setupCancelButton()
        setupSaveButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        layoutAnimatedImageView()
        layoutEditButton()
        layoutCancelButton()
        layoutSaveButton()
        setAnimatedImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Setup Subview
    private func setupAnimatedImageView() {
        self.animatedImageView = UIImageView(frame: CGRectMake(0, 0, kSCREEN_WIDTH - 60, kSCREEN_WIDTH - 60))
    }
    
    private func setupEditButton() {
        self.editButton = UIButton(frame: CGRectMake(0, 0, 150, 150))
        self.editButton.setImage(UIImage(named: "EditButtonNormal"), forState: .Normal)
        self.editButton.addTarget(self, action: Selector("editButtonPressed:"), forControlEvents: .TouchUpInside)
    }
    
    private func setupCancelButton() {
        self.cancelButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        self.cancelButton.setImage(UIImage(named: "CancelButtonNormal"), forState: .Normal)
        self.cancelButton.addTarget(self, action: Selector("cancelButtonPressed:"), forControlEvents: .TouchUpInside)
    }
    
    private func setupSaveButton() {
        self.saveButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        self.saveButton.setImage(UIImage(named: "SaveButtonNormal"), forState: .Normal)
        self.saveButton.addTarget(self, action: Selector("saveButtonPressed:"), forControlEvents: .TouchUpInside)
    }
    
    // MARK: - Layout Subviews
    private func layoutAnimatedImageView() {
        let animatedImageViewCenter = CGPoint(x: kSCREEN_WIDTH / 2.0,
            y: 30 + self.animatedImageView.frame.size.height / 2.0)
        self.animatedImageView.center = animatedImageViewCenter
        self.view.addSubview(self.animatedImageView)
    }
    
    private func layoutEditButton() {
        let editButtonCenter = CGPoint(x: kSCREEN_WIDTH / 2.0,
            y: (self.animatedImageView.frame.origin.y + self.animatedImageView.frame.size.height + kSCREEN_HEIGHT) / 2.0)
        self.editButton.center = editButtonCenter
        self.view.addSubview(self.editButton)
    }
    
    private func layoutCancelButton() {
        let cancelButtonCenter = CGPoint(x: (kSCREEN_WIDTH / 2.0 - self.editButton.frame.size.width / 2.0) / 2.0,
            y: self.editButton.center.y)
        self.cancelButton.center = cancelButtonCenter
        self.view.addSubview(self.cancelButton)
    }
    
    private func layoutSaveButton() {
        let saveButtonCenter = CGPoint(x: kSCREEN_WIDTH - self.cancelButton.center.x,
            y: self.editButton.center.y)
        self.saveButton.center = saveButtonCenter
        self.view.addSubview(self.saveButton)
    }
    
    // MARK: - Frame methods
    private func setAnimatedImage() {
        renderFrames()
        let animatedImage = UIImage.animatedImageWithImages(self.renderedFrames, duration: self.duration)
        self.animatedImageView.image = animatedImage
        self.animatedImageView.startAnimating()
    }
    
    private func processBitmaps() {
        self.frames = [[UIImage?]]()
        for cgImage in self.bitmaps {
            var frameArray = [UIImage?]()
            frameArray.append(UIImage(CGImage: cgImage))
            self.frames.append(frameArray)
        }
    }
    
    private func renderFrames() {
        if self.renderedFrames != nil {
            self.renderedFrames = nil
        }
        self.renderedFrames = [UIImage]()
        
        for frameArray in self.frames {
            if frameArray.count > 1 {
                let image = combineImages(frameArray)
                self.renderedFrames.append(image)
            } else {
                self.renderedFrames.append(frameArray.first!!)
            }
        }
    }
    
    private func combineImages(images: [UIImage?]) -> UIImage {
        let size = images.first!!.size
        UIGraphicsBeginImageContext(size)
        let areaSize = CGRectMake(0, 0, size.width, size.height)
        for image in images {
            if image != nil {
                image!.drawInRect(areaSize)
            }
        }
        let combinedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return combinedImage
    }
    
    func createGif() {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        let temporaryFile = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp")
        let fileOutputURL = NSURL(fileURLWithPath: temporaryFile)
        let destination = CGImageDestinationCreateWithURL(fileOutputURL, kUTTypeGIF, self.renderedFrames!.count, nil)
        let fileProperties = [kCGImagePropertyGIFDictionary as String:
            [
                kCGImagePropertyGIFLoopCount as String: 0
            ],
            kCGImageDestinationLossyCompressionQuality as String: 1.0]
        let frameProperties = [kCGImagePropertyGIFDictionary as String:
            [
                kCGImagePropertyGIFDelayTime as String: self.duration / Double(self.renderedFrames.count)
            ]]
        CGImageDestinationSetProperties(destination!, fileProperties as CFDictionaryRef)
        
        for frame in self.renderedFrames! {
            CGImageDestinationAddImage(destination!, frame.CGImage!, frameProperties as CFDictionaryRef)
        }
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            CGImageDestinationSetProperties(destination!, fileProperties as CFDictionaryRef)
            if CGImageDestinationFinalize(destination!) {
                
                CKBackendManager.sharedInstance.saveGif(fileOutputURL, withDuration: self.duration, completionBlock: { (taks) -> AnyObject? in
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(GIF_FINALIZED, object: fileOutputURL)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        })
                    }
                    
                    return nil
                })
            }
            
        }
    }

    
    // MARK: - Button Actions
    func cancelButtonPressed(sender: UIButton) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    func editButtonPressed(sender: UIButton) {
        
        if self.editViewController == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.editViewController = storyboard.instantiateViewControllerWithIdentifier("EditVC") as! CKEditViewController
            self.editViewController.frames = self.frames
            self.editViewController.delegate = self
        }
        
        self.presentViewController(self.editViewController, animated: true) { () -> Void in
            
        }
    }
    
    func saveButtonPressed(sender: UIButton) {
        createGif()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CKPreviewViewController: CKEditViewControllerDelegate {
    func willPresentNewFrames(frames: [[UIImage?]]) {
        self.frames = frames
        setAnimatedImage()
    }
}
