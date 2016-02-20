//
//  CKAddTextViewController.swift
//  Cake
//
//  Created by lola on 2/15/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit
import TTRangeSlider

typealias KVOContext = UInt8
var MyObservationContext = KVOContext()

class CKTextEffectViewController: UIViewController {
    
    @IBOutlet weak var previewFrame: UIImageView!
    @IBOutlet weak var previewFrameHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var rangeSlider: TTRangeSlider!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var textColorButton: UIButton!
    
    var colorPickerDataSource: CKColorPickerViewController!
    
    var delegate: CKTextViewControllerDelegate?
    var frames: [UIImage]!
    var textFrame: UIImage!
    var startFrameIndex: Int!
    var endFrameIndex: Int!
    var textView: UITextView!
    
    private var isFirstTextInput: Bool = true
    private var textViewLastLocation: CGPoint!
    private var textViewPanGestureRecognizer: UIPanGestureRecognizer!
    private var textViewPinchGestureRecognizer: UIPinchGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreviewFrame()
        setupRangeSlider()
        setupTextView()
        setupTextColorButton()
        setupFontSizeSlider()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        setupTextViewLayout()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        rangeSlider.removeObserver(self, forKeyPath: "selectedMinimum", context: &MyObservationContext)
        rangeSlider.removeObserver(self, forKeyPath: "selectedMaximum", context: &MyObservationContext)
    }
    
    // MARK: - Loading Setup
    private func setupFontSizeSlider() {
        self.fontSizeSlider.minimumValue = 20
        self.fontSizeSlider.maximumValue = 160
        self.fontSizeSlider.value = 72
    }
    
    private func setupTextColorButton() {
        self.textColorButton.backgroundColor = UIColor.whiteColor()
        self.textColorButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.textColorButton.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale 
        self.textColorButton.layer.cornerRadius = 4.0
        self.textColorButton.clipsToBounds = true
    }
    
    private func setupTextView() {
        self.textView = UITextView(frame: CGRectMake(0, 0, kSCREEN_WIDTH - 8, 100))
        let textViewCenter = CGPointMake(kSCREEN_WIDTH / 2.0, kSCREEN_WIDTH / 2.0)
        self.textView.scrollEnabled = false
        self.textView.secureTextEntry = true
        
        self.textView.layer.borderWidth = 0.5
        self.textView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.textView.delegate = self
        self.textView.contentInset = UIEdgeInsetsZero
        self.textView.font = UIFont(name: "Helvetica-Bold", size: 72)
        
        self.textView.text = "TESTIN"
        self.textView.sizeToFit()
        self.textView.frame.size.width = kSCREEN_WIDTH - 8
        self.textView.text = ""
        self.textView.center = textViewCenter
        self.textView.textContainerInset = UIEdgeInsetsZero
        
        self.textView.tintColor = UIColor.whiteColor()
        self.textView.backgroundColor = UIColor.clearColor()
        self.textView.textColor = UIColor.whiteColor()
        self.textView.textAlignment = .Center
        self.textView.returnKeyType = .Done
        self.textView.textContainer.maximumNumberOfLines = 1
        
        self.textViewPanGestureRecognizer = UIPanGestureRecognizer()
        self.textViewPanGestureRecognizer.addTarget(self, action: Selector("panTextView:"))
        
        self.textViewPinchGestureRecognizer = UIPinchGestureRecognizer()
        self.textViewPinchGestureRecognizer.addTarget(self, action: "pinchTextView:")
       
        allowTextViewGestures(true)
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
        
        self.startFrameIndex = 0
        self.endFrameIndex = self.frames.count - 1
    }
    
    
    
    // MARK: - Layout Subviews
    private func setupTextViewLayout() {
        self.view.insertSubview(self.textView, belowSubview: self.settingsView)
        if self.textView.text == "" {
            self.textView.becomeFirstResponder()
        }
    }
    
    // MARK: - Processes
    private func allowTextViewGestures(allow: Bool) {
        if allow {
            self.textView.addGestureRecognizer(self.textViewPanGestureRecognizer)
//            self.textView.addGestureRecognizer(self.textViewPinchGestureRecognizer)
        } else {
            self.textView.removeGestureRecognizer(self.textViewPanGestureRecognizer)
//            self.textView.removeGestureRecognizer(self.textViewPinchGestureRecognizer)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.rangeSlider.hidden = true
        setNeedsFocusUpdate()
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.rangeSlider.hidden = false
        setNeedsFocusUpdate()
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
                self.startFrameIndex = new - 1
                updateFrame(new)
                print("selectedMinimum changed: \(new)")
                
            case("selectedMaximum", &MyObservationContext):
                self.endFrameIndex = new - 1
                updateFrame(new)
                print("selectedMaximum changed: \(new)")
                
            case(_, &MyObservationContext):
                assert(false, "unknown key path")
                
            default:
                super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            }
        }
    }
    
    // MARK: - Text View Methods
    func panTextView(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(self.view)

        print(translation)
        
        let topEdgeOffest = sender.view!.center.y + translation.y - sender.view!.frame.height / 2.0
        let bottomEdgeOffset = sender.view!.center.y + translation.y + sender.view!.frame.height / 2.0
        let leftEdgeOffset = sender.view!.center.x + translation.x - sender.view!.frame.width / 2.0
        let rightEdgeOffest = sender.view!.center.x + translation.x + sender.view!.frame.width / 2.0
        
        
        if bottomEdgeOffset < kSCREEN_WIDTH + sender.view!.frame.size.height / 2.0 &&
            topEdgeOffest > -sender.view!.frame.size.height / 2.0 &&
            leftEdgeOffset > -sender.view!.frame.size.width / 2.0 &&
            rightEdgeOffest < kSCREEN_WIDTH + sender.view!.frame.size.width / 2.0 {
                
                
            sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
                
                
        } else if (bottomEdgeOffset >= kSCREEN_WIDTH + sender.view!.frame.size.height / 2.0 && translation.y < 0 ) {

            sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
            
            
        } else if (rightEdgeOffest >= kSCREEN_WIDTH + sender.view!.frame.size.width / 2.0  && translation.x < 0 ) {
            
            sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
            
            
        }
        
        
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
//    func pinchTextView(sender: UIPinchGestureRecognizer) {
//        
//        print(sender.scale)
//        
//        let topEdgeOffest = sender.view!.frame.origin.y
//        let bottomEdgeOffset = sender.view!.frame.height + sender.view!.frame.origin.y
//        let leftEdgeOffset = sender.view!.frame.origin.x
//        let rightEdgeOffest = sender.view!.frame.width + sender.view!.frame.origin.x
//        
//        if topEdgeOffest > 0 && bottomEdgeOffset < kSCREEN_WIDTH && leftEdgeOffset > 0 && rightEdgeOffest < kSCREEN_WIDTH && sender.scale > 1 {
//            self.textView.transform = CGAffineTransformScale(self.textView.transform, sender.scale, sender.scale)
//        } else if sender.scale < 1 && sender.view?.frame.height > 100 {
//            self.textView.transform = CGAffineTransformScale(self.textView.transform, sender.scale, sender.scale)
//        }
//        
//        sender.scale = 1
//    }
    
    // MARK: - Frame Methods
    private func updateFrame(index: Int) {
        self.previewFrame.image = self.frames[index-1]
    }
    
    private func createTextFrame() -> UIImage {
        let text: NSString = self.textView.text as NSString
        let textFontAttributes: [String: AnyObject] = [NSFontAttributeName: self.textView.font!, NSForegroundColorAttributeName: self.textView.textColor!]
        UIGraphicsBeginImageContext(self.previewFrame.frame.size)
        text.drawInRect(self.textView.frame, withAttributes: textFontAttributes)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    // MARK: - Actions
    @IBAction func fontSizeSliderValueChanged(sender: UISlider) {
        self.textView.font = UIFont(name: "Helvetica-Bold", size: CGFloat(sender.value))
        let string: NSString = self.textView.text as NSString
        var size = string.sizeWithAttributes([NSFontAttributeName: (self.textView.font)!])
        size.width = size.width + 20
        self.textView.frame.size = size
        self.textView.setNeedsLayout()
    }
    
    @IBAction func colorButtonPressed(sender: AnyObject) {
        if self.colorPickerDataSource == nil {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.colorPickerDataSource  = storyboard.instantiateViewControllerWithIdentifier("ColorPickerVC") as! CKColorPickerViewController
            self.colorPickerDataSource.delegate = self
        }
        
        self.presentViewController(self.colorPickerDataSource, animated: true) { () -> Void in
            
        }
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        
        if self.textView.text != "" {
            self.textFrame = createTextFrame()
            self.delegate?.updateTextController(self, addTextFrame: self.textFrame!, fromStartFrameIndex: self.startFrameIndex!, toEndFrame: self.endFrameIndex!)
        } else {
            self.delegate?.removeTextController(self)
        }
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
}

extension CKTextEffectViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        allowTextViewGestures(false)
        
        if self.isFirstTextInput == false {
            textView.frame.size.width = kSCREEN_WIDTH - textView.frame.origin.x - 5
        }
    }
    
    func sizeOfString (string: String, constrainedToWidth width: Double, font: UIFont) -> CGSize {
        return (string as NSString).boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: font],
            context: nil).size
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            
            let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
            let trimmedText = textView.text.stringByTrimmingCharactersInSet(whitespaceSet)
            textView.text = trimmedText
            if trimmedText == "" {
                textView.frame.size = CGSizeMake(textView.frame.height, textView.frame.height)
            } else {
                textView.sizeToFit()
            }
            
            if self.isFirstTextInput {
                self.isFirstTextInput = false
                self.textView.center = CGPointMake(kSCREEN_WIDTH / 2.0, kSCREEN_WIDTH / 2.0)
                self.textView.textAlignment = .Left
            }
            
            textView.resignFirstResponder()
            allowTextViewGestures(true)
            
            return false
        }
        
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        var textWidth = CGRectGetWidth(UIEdgeInsetsInsetRect(textView.frame, textView.textContainerInset))
        textWidth -= 2.0 * textView.textContainer.lineFragmentPadding;
        
        let boundingRect = sizeOfString(newText, constrainedToWidth: Double(textWidth), font: textView.font!)
        let numberOfLines = boundingRect.height / textView.font!.lineHeight;
        
        return numberOfLines <= 1;
    }
}

extension CKTextEffectViewController: CKColorPickerViewDelegate {
    func updateColor(color: UIColor) {
        self.textColorButton.backgroundColor = color
        self.textView.textColor = color
        setNeedsFocusUpdate()
    }
}

protocol CKTextViewControllerDelegate {
    func removeTextController(controller: CKTextEffectViewController)
    func updateTextController(controller: CKTextEffectViewController, addTextFrame textFrame: UIImage, fromStartFrameIndex startFrameIndex: Int, toEndFrame endFrameIndex: Int)
}