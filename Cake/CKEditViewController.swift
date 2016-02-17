//
//  CKEditViewController.swift
//  Cake
//
//  Created by lola on 2/4/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices
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
    @IBOutlet weak var effectsTableView: UITableView!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewGifImageView: UIImageView!
    @IBOutlet weak var previewGifImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    var state: EditMode = .Preview
    var duration: Double!
    var framesPerSecond: Int!
    var gifURL: NSURL!
    
    var rawFrames: [CGImage]!
    var cleanFrames: [UIImage]!
    var frames: [[UIImage?]] = [[UIImage?]]()
    var flattenFrames : [UIImage]!
    
    var textEffects: [CKTextEffectViewController]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGif()
        setupFramesLabel()
        setupCarousel()
        setupEffectsTableView()
        setupFramesSlider()
    }
    
    // MARK: - Setup Methods
    private func setupGif() {
        for frame in rawFrames {
            var frameImages = [UIImage?]()
            frameImages.append(UIImage(CGImage: frame))
            self.frames.append(frameImages)
        }
        
        self.cleanFrames = [UIImage]()
        
        for frameSet in self.frames {
            cleanFrames.append(frameSet.first!!)
        }
        
        self.previewGifImageViewHeightConstraint.constant = kSCREEN_WIDTH - 60
        setNeedsFocusUpdate()
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
    
    private func setupEffectsTableView() {
        let addEffectNibName = UINib(nibName: "CKAddEffectTableViewCell", bundle:nil)
        self.effectsTableView.registerNib(addEffectNibName, forCellReuseIdentifier: addEffectTableViewCellReuse)
        let textAuxiliaryNibName = UINib(nibName: "CKTextEffectAuxiliaryTableViewCell", bundle:nil)
        self.effectsTableView.registerNib(textAuxiliaryNibName, forCellReuseIdentifier: textEffectAuxiliaryTableViewCellReuse)
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
            self.effectsTableView.reloadData()
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
    
    // MARK: - Button Actions
    @IBAction func redoButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        self.state = .Edit
        self.previewGifImageView.stopAnimating()
        updateState()
        setNeedsFocusUpdate()
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        createGif()
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
    
    private func addEffect() {
        if self.textEffects == nil {
            self.textEffects = [CKTextEffectViewController]()
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let textEffectVC = storyboard.instantiateViewControllerWithIdentifier("AddTextVC") as! CKTextEffectViewController
        textEffectVC.frames = self.cleanFrames
        textEffectVC.delegate = self
        self.textEffects.append(textEffectVC)
        
        // append row of nils for effect
        for (index, _) in self.frames.enumerate() {
            self.frames[index].append(nil)
        }
        
        self.presentViewController(self.textEffects.last!, animated: true) { () -> Void in
            
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowAddText" {
            let addTextVC = segue.destinationViewController as! CKTextEffectViewController
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
                self.flattenFrames.append(frameSet.first!!)
            }
        }
    }
    
    private func mergeImages(images: [UIImage?]) -> UIImage {
        let size = images.first!!.size
        UIGraphicsBeginImageContext(size)
        let areaSize = CGRectMake(0, 0, size.width, size.height)
        for image in images {
            if image != nil {
                image!.drawInRect(areaSize)
            }
        }
        let flattenedFrame: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return flattenedFrame
    }
    
    func createGif() {
        if self.flattenFrames == nil {
            self.flattenFrames = self.cleanFrames
        }
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        let temporaryFile = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp")
        let fileOutputURL = NSURL(fileURLWithPath: temporaryFile)
        let destination = CGImageDestinationCreateWithURL(fileOutputURL, kUTTypeGIF, self.flattenFrames!.count, nil)
        let fileProperties = [kCGImagePropertyGIFDictionary as String:
            [
                kCGImagePropertyGIFLoopCount as String: 0
            ],
            kCGImageDestinationLossyCompressionQuality as String: 1.0]
        let frameProperties = [kCGImagePropertyGIFDictionary as String:
            [
                kCGImagePropertyGIFDelayTime as String: self.duration / Double(self.flattenFrames.count)
            ]]
        CGImageDestinationSetProperties(destination!, fileProperties as CFDictionaryRef)
        
        for frame in self.flattenFrames! {
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
    
}

// MARK: - Text Effect Delegate
extension CKEditViewController: CKAddTextViewControllerDelegate {
    
    func addTextController(controller: CKTextEffectViewController, addTextFrame textFrame: UIImage, fromStartFrameIndex startFrameIndex: Int, toEndFrame endFrameIndex: Int) {
        
        // Determine text effect index
        var effectIndex: Int?
        for effectVC in self.textEffects {
            if controller == effectVC {
                effectIndex = self.textEffects.indexOf(effectVC)! + 1
            }
        }
        
        // clear old frames
        for (index, _) in self.frames.enumerate() {
            if self.frames[index][effectIndex!] != nil {
                self.frames[index][effectIndex!] = nil
            }
        }
        
        // append frame to fx chain
        for index in startFrameIndex...endFrameIndex {
            self.frames[index][effectIndex!] = textFrame
        }
        
        for (index, frameSet) in self.frames.enumerate() {
            print("INDEX: ", index, "FRAMES: ", frameSet.count)
        }
        
        self.carousel.reloadData()
        self.carousel.scrollToItemAtIndex(startFrameIndex, animated: false)
    }
}

// MARK: - Table View Delegate, DataSource
extension CKEditViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.textEffects == nil {
            return 1
        } else {
            return 1 + self.textEffects.count
        }

    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        
        let height: CGFloat
        
        if self.textEffects == nil {
            height = CGFloat(44.0)
            
        } else {
            if index < (self.textEffects.count) {
                height = self.effectsTableView.frame.height / 4.0
                
            } else {
                height = CGFloat(44.0)
                
            }
        }
        
        return height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        
        if self.textEffects == nil {
            let cell = tableView.dequeueReusableCellWithIdentifier(addEffectTableViewCellReuse) as! CKAddEffectTableViewCell
            cell.delegate = self
            return cell
            
        } else {
            if index < (self.textEffects.count) {
                
                let cell = tableView.dequeueReusableCellWithIdentifier(textEffectAuxiliaryTableViewCellReuse) as! CKTextEffectAuxiliaryTableViewCell
                cell.delegate = self
                cell.setDataFromDataSource(self.textEffects[index])
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(addEffectTableViewCellReuse) as! CKAddEffectTableViewCell
                cell.delegate = self
                return cell
            }
        }
    }
    
}

// MARK: - Text Effect Auxiliary Cell Delegate
extension CKEditViewController: CKTextEffectAuxiliaryTableViewCellDelegate {
    
    func updateFramesFor(controller: CKTextEffectViewController, withTextFrame textFrame: UIImage, fromStartFrameIndex startFrameIndex: Int, toEndFrame endFrameIndex: Int) {
        
        // Determine text effect index
        var effectIndex: Int?
        for effectVC in self.textEffects {
            if controller == effectVC {
                effectIndex = self.textEffects.indexOf(effectVC)! + 1
            }
        }
        
        // clear old frames
        for (index, _) in self.frames.enumerate() {
            if self.frames[index][effectIndex!] != nil {
                self.frames[index][effectIndex!] = nil
            }
        }
        
        // append frame to fx chain
        for index in startFrameIndex...endFrameIndex {
            self.frames[index][effectIndex!] = textFrame
        }
        
        for (index, frameSet) in self.frames.enumerate() {
            print("INDEX: ", index, "FRAMES: ", frameSet.count)
        }
        
        self.carousel.reloadData()
    }
    
    func auxiliaryTableViewCell(auxiliaryCell: CKTextEffectAuxiliaryTableViewCell, didUpdateStartIndexTo startIndex: Int) {
        
        let effectIndex = getEffectIndexForEffectViewController(auxiliaryCell.viewControllerDataSource)
        self.textEffects[effectIndex].rangeSlider.selectedMinimum = auxiliaryCell.rangeSlider.selectedMinimum
        
        updateFramesFor(auxiliaryCell.viewControllerDataSource, withTextFrame: auxiliaryCell.viewControllerDataSource.textFrame, fromStartFrameIndex: startIndex, toEndFrame: Int(auxiliaryCell.rangeSlider.selectedMaximum - 1.0))
    }
    
    func auxiliaryTableViewCell(auxiliaryCell: CKTextEffectAuxiliaryTableViewCell, didUpdateEndIndexTo endIndex: Int) {
        
        let effectIndex = getEffectIndexForEffectViewController(auxiliaryCell.viewControllerDataSource)
        self.textEffects[effectIndex].rangeSlider.selectedMaximum = auxiliaryCell.rangeSlider.selectedMaximum
        
        updateFramesFor(auxiliaryCell.viewControllerDataSource, withTextFrame: auxiliaryCell.viewControllerDataSource.textFrame, fromStartFrameIndex: Int(auxiliaryCell.rangeSlider.selectedMinimum - 1.0), toEndFrame: endIndex)
    }
    
    func didPressOpenButton(cell: CKTextEffectAuxiliaryTableViewCell) {
        let effectIndex = getEffectIndexForEffectViewController(cell.viewControllerDataSource)
        self.presentViewController(self.textEffects[effectIndex], animated: true) { () -> Void in
            
        }
    }
    
    func didPressDeleteButton(cell: CKTextEffectAuxiliaryTableViewCell) {
        
    }
    
    private func getEffectIndexForEffectViewController(effectVC: CKTextEffectViewController) -> Int {
        return self.textEffects.indexOf(effectVC)!
    }
}

// MARK: - Add Effect Delegate
extension CKEditViewController: CKAddEffectTableViewCellDelegate {
    func didPressAddEffectButton(cell: CKAddEffectTableViewCell) {
        addEffect()
    }
}

// MARK: - Carousel Delegate, DataSource
extension CKEditViewController: iCarouselDataSource, iCarouselDelegate {
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return self.frames.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        
        var frameView: UIView
        
        if (view == nil) {
            frameView = UIView(frame: CGRectMake(0, 0, 240, 240))
        } else {
            frameView = view!
            for subview in frameView.subviews {
                subview.removeFromSuperview()
            }
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


