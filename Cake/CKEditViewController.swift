//
//  CKEditViewController.swift
//  Cake
//
//  Created by lola on 2/4/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit

class CKEditViewController: UIViewController {
    
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var frameSlider: UISlider!
    @IBOutlet weak var framesLabel: UILabel!
    @IBOutlet weak var effectsTableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var delegate: CKEditViewControllerDelegate?
    var frames: [[UIImage?]]!
    var cleanFrames: [UIImage]!
    var textEffects: [CKTextEffectViewController]!
    
    private var frameQueue: dispatch_queue_t!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFramesLabel()
        setupCarousel()
        setupFramesSlider()
        setupEffectsTableView()
        self.frameQueue = dispatch_queue_create("com.cakegifs.FrameQueue", nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.effectsTableView.layoutSubviews()
        self.effectsTableView.reloadData()
        
        self.activityIndicator.hidden = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Setup Methods
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
    
    // MARK: - Layout Subview
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Actions
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
    
    private func addEffect() {
        if self.textEffects == nil {
            self.textEffects = [CKTextEffectViewController]()
            self.cleanFrames = [UIImage]()
            for frameArray in self.frames {
                self.cleanFrames.append(frameArray.first!!)
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let textEffectVC = storyboard.instantiateViewControllerWithIdentifier("AddTextVC") as! CKTextEffectViewController
        textEffectVC.frames = self.cleanFrames
        textEffectVC.delegate = self
        self.textEffects.append(textEffectVC)
        
        for (index, _) in self.frames.enumerate() {
            self.frames[index].append(nil)
        }
        
        self.presentViewController(self.textEffects.last!, animated: true) { () -> Void in
            
        }
    }
    
    private func removeEffect(effectIndex: Int) {
        
        // remove frames for index
        for (index, _) in self.frames.enumerate() {
            self.frames[index].removeAtIndex(effectIndex + 1)
        }
        
        // remove view controller in effect chain
        self.textEffects.removeAtIndex(effectIndex)
        
        self.effectsTableView.reloadData()
        self.carousel.reloadData()
    }
    
    @IBAction func playButtonPressed(sender: AnyObject) {
        
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        
        self.delegate?.willPresentNewFrames(self.frames)
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.activityIndicator.hidden = true
            self.activityIndicator.stopAnimating()
        }
    }
}

// MARK: - Text Effect Delegate
extension CKEditViewController: CKTextViewControllerDelegate {
    
    func removeTextController(controller: CKTextEffectViewController) {
        self.removeEffect(getEffectIndexForEffectViewController(controller))
    }
    
    func updateTextController(controller: CKTextEffectViewController, addTextFrame textFrame: UIImage, fromStartFrameIndex startFrameIndex: Int, toEndFrame endFrameIndex: Int) {
        
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
        
        // 4 inch retina
        if kSCREEN_HEIGHT < 569.0 {
            return self.effectsTableView.frame.height / 3.0
        } else {
            return self.effectsTableView.frame.height / 4.0
        }
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
        
        let alert = UIAlertController(title: "Remove Effect?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            print("Cancelled Delete")
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
            
            let effectIndex = self.getEffectIndexForEffectViewController(cell.viewControllerDataSource)
            self.removeEffect(effectIndex)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
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
        
        let carouselHeight = carousel.frame.height
        
        var frameView: UIView
        
        if (view == nil) {
            frameView = UIView(frame: CGRectMake(0, 0, carouselHeight, carouselHeight))
        } else {
            frameView = view!
            for subview in frameView.subviews {
                subview.removeFromSuperview()
            }
        }
        
        for frame in self.frames[index] {
            let imageView = UIImageView(frame: CGRectMake(0, 0, carouselHeight, carouselHeight))
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

protocol CKEditViewControllerDelegate {
    func willPresentNewFrames(frames: [[UIImage?]])
}

