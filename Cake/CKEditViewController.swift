//
//  CKEditViewController.swift
//  Cake
//
//  Created by lola on 2/4/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
//import FLAnimatedImage

struct EditableGIF {
    var gifURL: NSURL!
    var duration: Double!
    var fps: Int!
    
    init(url: NSURL, duration: Double, fps: Int) {
        self.gifURL = url
        self.duration = duration
        self.fps = fps
    }
}

enum EditMode {
    case Preview
    case Edit
}

class CKEditViewController: UIViewController {
    
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var carousel: iCarousel!
    
    @IBOutlet weak var frameSlider: UISlider!
    @IBOutlet weak var framesLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var addTextButton: UIButton!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewGifImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var state: EditMode = .Preview
    var duration: Double!
    var framesPerSecond: Int!
    var gifURL: NSURL!
    
    var rawFrames: [CGImage]!
    var cleanFrames: [UIImage]!
    var frames: [[UIImage]] = [[UIImage]]()
    var flattenFrames : [UIImage]!
    
    var textEffects: [CKAddTextViewController]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saveButton.enabled = false
        setupGif()
        setupFramesLabel()
        setupCarousel()
        setupAddTextButton()
        setupFramesSlider()
    }
    
    private func setupGif() {
        for frame in rawFrames {
            var frameImages = [UIImage]()
            frameImages.append(UIImage(CGImage: frame))
            self.frames.append(frameImages)
        }
        
        self.cleanFrames = [UIImage]()
        
        for frameSet in self.frames {
            cleanFrames.append(frameSet.first!)
        }
        
        let gif = UIImage.animatedImageWithImages(cleanFrames, duration: NSTimeInterval(self.duration))
        self.previewGifImageView.image = gif
        self.previewGifImageView.startAnimating()
    }
    
    private func setupFramesLabel() {
        self.framesLabel.text = "1 of \(self.frames.count)"
    }
    
    private func setupFramesSlider() {
        self.frameSlider.minimumValue = 0.0
        self.frameSlider.maximumValue = 1.0
        self.frameSlider.value = 0.0
    }
    
    private func setupCarousel() {
        self.carousel.type = .CoverFlow
        self.carousel.bounces = false
        self.carousel.reloadData()
        self.carousel.scrollToItemAtIndex(0, animated: false)
    }
    
    private func setupAddTextButton() {
        self.addTextButton.layer.cornerRadius = 4.0
        self.addTextButton.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateState()
    }
    
    func updateState() {
        if self.state == .Preview {
            self.previewView.hidden = false
            self.editView.hidden = true
        } else if self.state == .Edit {
            self.previewView.hidden = true
            self.editView.hidden = false
        }
    }

    func setAnimatedImage(notification: NSNotification) {
        let imageSize: Int = NSData(contentsOfURL: gifURL)!.length
        print("size of image in MB: ", Float(imageSize) / 1024.0 / 1000.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func redoButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }

    // MARK: - Button Actions
    @IBAction func editButtonPressed(sender: AnyObject) {
        self.state = .Edit
        self.previewGifImageView.stopAnimating()
        updateState()
        setNeedsFocusUpdate()
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {

    }
    
    @IBAction func frameSliderValueChanged(sender: AnyObject) {
        let frameIndex = Int(self.frameSlider.value * Float(self.frames.count-1))
        if frameIndex != self.carousel.currentItemIndex {
            updateFramesLabel(frameIndex)
            self.carousel.scrollToItemAtIndex(frameIndex, animated: false)
        }
    }
    
    private func updateFramesLabel(index: Int) {
        self.framesLabel.text = "\(index + 1) of \(self.frames.count)"
    }
    
    @IBAction func playButtonPressed(sender: AnyObject) {
        self.state = .Preview
        
        flattenPreviewFrames()
        let gif = UIImage.animatedImageWithImages(self.flattenFrames, duration: NSTimeInterval(self.duration))
        self.previewGifImageView.image = gif
        
        self.previewGifImageView.startAnimating()
        updateState()
        setNeedsFocusUpdate()
    }
    
    @IBAction func addTextButtonPressed(sender: AnyObject) {
        
        if self.textEffects == nil {
            self.textEffects = [CKAddTextViewController]()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let textEffectVC = storyboard.instantiateViewControllerWithIdentifier("AddTextVC") as! CKAddTextViewController
            textEffectVC.frames = self.cleanFrames
            textEffectVC.delegate = self
            self.textEffects.append(textEffectVC)
        }
        
        self.presentViewController(self.textEffects.first!, animated: true) { () -> Void in
            
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowAddText" {
            let addTextVC = segue.destinationViewController as! CKAddTextViewController
            addTextVC.frames = self.cleanFrames
        }
    }
    
    // MARK: - Gif Methods
    private func flattenPreviewFrames() {
        if self.flattenFrames != nil {
            self.flattenFrames = nil
        }
        self.flattenFrames = [UIImage]()
        for frameSet in self.frames {
            if frameSet.count > 1 {
                let image = mergeImages(frameSet)
                self.flattenFrames.append(image)
            } else {
                self.flattenFrames.append(frameSet.first!)
            }
        }
    }
    
    private func mergeImages(images: [UIImage]) -> UIImage {
        let size = images.first?.size
        UIGraphicsBeginImageContext(size!)
        let areaSize = CGRectMake(0, 0, size!.width, size!.height)
        for image in images {
            image.drawInRect(areaSize)
        }
        let flattenedFrame: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return flattenedFrame
    }

}

extension CKEditViewController: CKAddTextViewControllerDelegate {
    func addTextFrameTo(textFrame: UIImage, fromStartFrameIndex startFrameIndex: Int, toEndFrame endFrameIndex: Int) {
        for index in startFrameIndex...endFrameIndex {
            self.frames[index].append(textFrame)
        }
        self.carousel.scrollToItemAtIndex(startFrameIndex, animated: false)
    }
}

extension CKEditViewController: iCarouselDataSource, iCarouselDelegate {
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return self.frames.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        
        var frameView: UIView
        
        if (view == nil) {
            frameView = UIView(frame: CGRectMake(0, 0, 240, 240))
        } else {
            for subview in (view?.subviews)! {
                subview.removeFromSuperview()
            }
            frameView = view!
        }
        
        for frame in self.frames[index] {
            let imageView = UIImageView(frame: CGRectMake(0, 0, 240, 240))
            imageView.image = frame
            frameView.addSubview(imageView)
        }
        
        return frameView
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .Spacing)
        {
            return value * 1.1
        }
        return value
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        let index = carousel.currentItemIndex
        let value = Float(index) / Float(self.frames.count-1)
        self.frameSlider.value = Float(value)
        let frameIndex = Int(self.frameSlider.value * Float(self.frames.count-1))
        updateFramesLabel(frameIndex)
    }
}


