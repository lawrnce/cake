//
//  CKAddTextViewController.swift
//  Cake
//
//  Created by lola on 2/15/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import TTRangeSlider

class CKAddTextViewController: UIViewController {
    
    @IBOutlet weak var previewFrame: UIImageView!
    @IBOutlet weak var previewFrameHeightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var textSizeSegmentedControl: UISegmentedControl!
    
    
    @IBOutlet weak var rangeSlider: TTRangeSlider!
    
    @IBOutlet weak var doneButton: UIButton!
    
    var frames: [UIImage]!
    var textFrames: [UIImage]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreviewFrame()
        setupRangeSlider()
    }
    
    deinit {
        rangeSlider.removeObserver(self, forKeyPath: "selectedMinimum", context: &MyObservationContext)
        rangeSlider.removeObserver(self, forKeyPath: "selectedMaximum", context: &MyObservationContext)
    }
    
    private func setupPreviewFrame() {
        self.previewFrameHeightConstant.constant = kSCREEN_WIDTH
        setNeedsFocusUpdate()
        self.previewFrame.image = self.frames.first
        self.previewFrame.contentMode = .ScaleAspectFit
    }
    
    private func setupRangeSlider() {
        self.rangeSlider.minValue = 1.0
        self.rangeSlider.maxValue = Float(self.frames.count)
        self.rangeSlider.selectedMinimum = 1
        self.rangeSlider.selectedMaximum = self.rangeSlider.maxValue
        
        let options = NSKeyValueObservingOptions([.New, .Old])
        self.rangeSlider.addObserver(self, forKeyPath: "selectedMinimum", options: options, context: &MyObservationContext)
        self.rangeSlider.addObserver(self, forKeyPath: "selectedMaximum", options: options, context: &MyObservationContext)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Key Value Observing
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard keyPath != nil else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        let old = Int(round(change!["old"] as! Double))
        let new = Int(round(change!["new"] as! Double))
        
        if old == new {
            return
        } else {
            switch (keyPath!, context) {
            case("selectedMinimum", &MyObservationContext):
                updateFrame(new)
                print("selectedMinimum changed: \(new)")
                
            case("selectedMaximum", &MyObservationContext):
                updateFrame(new)
                print("selectedMaximum changed: \(new)")
                
            case(_, &MyObservationContext):
                assert(false, "unknown key path")
                
            default:
                super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            }
        }
    }
    
    // MARK: - Frame Methods
    private func updateFrame(index: Int) {
        self.previewFrame.image = self.frames[index-1]
    }
    
    // MARK: - Button Actions
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
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

typealias KVOContext = UInt8
var MyObservationContext = KVOContext()

class RangeSliderObserver: NSObject {
    
    func startObservingRangeSlider(rangeSlider: TTRangeSlider) {
        let options = NSKeyValueObservingOptions([.New, .Old])
        rangeSlider.addObserver(self, forKeyPath: "selectedMinimum", options: options, context: &MyObservationContext)
        rangeSlider.addObserver(self, forKeyPath: "selectedMaximum", options: options, context: &MyObservationContext)
    }
    
    func stopObservingPerson(rangeSlider: TTRangeSlider) {
        rangeSlider.removeObserver(self, forKeyPath: "selectedMinimum", context: &MyObservationContext)
        rangeSlider.removeObserver(self, forKeyPath: "selectedMaximum", context: &MyObservationContext)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard keyPath != nil else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        let old = Int(round(change!["old"] as! Double))
        let new = Int(round(change!["new"] as! Double))
        
        if old == new {
            return
        } else {
            switch (keyPath!, context) {
            case("selectedMinimum", &MyObservationContext):
                print("selectedMinimum changed: \(new)")
                
            case("selectedMaximum", &MyObservationContext):
                print("selectedMaximum changed: \(new)")
                
            case(_, &MyObservationContext):
                assert(false, "unknown key path")
                
            default:
                super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            }
        }
    }
}
