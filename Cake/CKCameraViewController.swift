//
//  ViewController.swift
//  Cake
//
//  Created by lola on 2/13/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit

class CKCameraViewController: UIViewController {

    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timeViewWidthConstraint: NSLayoutConstraint!
    
    var cameraController: CKGifCameraController!
    
    private var cancelRecordingButton: LTColorPanningButton!
    private var cameraToggleButton: LTColorPanningButton!
    private var torchButton: LTColorPanningButton!
    private var finishRecordingButton: LTColorPanningButton!
    
    private var previewView: CKPreviewView!
    private var recordButtonImageView: UIImageView!
    private var gifsButton: UIButton!
    private var state: CameraState = .Idle
    private var gifToDisplay: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraController()
        setupPreviewView()
        setupRecordButtonImageView()
        setupGifsButton()
        setupCancelButton()
        setupFinishButton()
        setupCameraToggleButton()
        setupTorchButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let recordButtonCenter = CGPointMake(kSCREEN_WIDTH / 2.0, ((64.0 + kSCREEN_WIDTH ) + kSCREEN_HEIGHT) / 2.0)
        self.recordButtonImageView.center = recordButtonCenter
        
        let gifsButtonCenter = CGPointMake(((kSCREEN_WIDTH / 2.0 + self.recordButtonImageView.frame.width / 2.0) + kSCREEN_WIDTH) / 2.0, recordButtonCenter.y)
        self.gifsButton.center = gifsButtonCenter
        
        if self.timeViewWidthConstraint.constant != CGFloat(0.0) {
            self.timeViewWidthConstraint.constant = CGFloat(0.0)
            setNeedsFocusUpdate()
        }
        
        self.recordingView.addSubview(self.cancelRecordingButton)
        self.recordingView.addSubview(self.finishRecordingButton)
        self.recordingView.addSubview(self.torchButton)
        self.recordingView.addSubview(self.cameraToggleButton)
        self.recordingView.layoutIfNeeded()
        
        self.cancelRecordingButton.resetColor()
        self.finishRecordingButton.resetColor()
        self.cameraToggleButton.resetColor()
        self.torchButton.resetColor()
        
        self.view.addSubview(previewView)
        self.view.addSubview(self.recordButtonImageView)
        self.view.addSubview(self.gifsButton)
        updateStateLayout(false)
        
        self.cameraController.startSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .None
    }

    // MARK: - State Managerment
    private func updateStateLayout(animated: Bool) {
        if self.state == .Idle {
            
            if animated {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.cancelRecordingButton.alpha = 0.0
                    self.finishRecordingButton.alpha = 0.0
                    self.cameraToggleButton.center.x = kSCREEN_WIDTH * (1.0/3.0)
                    self.torchButton.center.x = kSCREEN_WIDTH * (2.0/3.0)
                    
                    }, completion: { (done) -> Void in
                        
                        self.cancelRecordingButton.hidden = true
                        self.finishRecordingButton.hidden = true
                })
            } else {
                self.cancelRecordingButton.alpha = 0.0
                self.finishRecordingButton.alpha = 0.0
                self.cameraToggleButton.center.x = kSCREEN_WIDTH * (1.0/3.0)
                self.torchButton.center.x = kSCREEN_WIDTH * (2.0/3.0)
                self.cancelRecordingButton.hidden = true
                self.finishRecordingButton.hidden = true
            }
            
            self.gifsButton.hidden = false
        } else if self.state == .Recording {
            
            
            if animated {
                self.cancelRecordingButton.hidden = false
                self.finishRecordingButton.hidden = false
                self.cancelRecordingButton.alpha = 0.0
                self.finishRecordingButton.alpha = 0.0
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.cancelRecordingButton.alpha = 1.0
                    self.finishRecordingButton.alpha = 1.0
                    self.cameraToggleButton.frame.origin.x = kToggleButtonFrameOriginX
                    self.torchButton.frame.origin.x = kTorchButtonFrameOriginX
                    
                    }, completion: { (done) -> Void in
                        
                })
                
            } else {
                self.cancelRecordingButton.hidden = false
                self.finishRecordingButton.hidden = false
                self.cancelRecordingButton.alpha = 1.0
                self.finishRecordingButton.alpha = 1.0
                self.cameraToggleButton.frame.origin.x = kToggleButtonFrameOriginX
                self.torchButton.frame.origin.x = kTorchButtonFrameOriginX
            }
        
            self.gifsButton.hidden = true
        }
        self.view.insertSubview(self.timerView, belowSubview: self.recordingView)
        setNeedsFocusUpdate()
    }
    
    
    // MARK: - Init Subviews
    private func setupCameraController() {
        // Setup Camera Controller
        self.cameraController = CKGifCameraController()
        
        do {
            if try self.cameraController.setupSession() {
                self.cameraController.delegate = self
            }
        }
        catch CKCameraError.FailedToAddInput {
            
        }
        catch CKCameraError.FailedToAddOutput {
            
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func setupPreviewView() {
        let eaglContext = CKContextManager.sharedInstance.eaglContext
        self.previewView = CKPreviewView(frame: CGRectMake(0, 64.0, kSCREEN_WIDTH, kSCREEN_WIDTH), context: eaglContext)
        self.previewView.coreImageContext = CKContextManager.sharedInstance.ciContext
        self.cameraController.imageTarget = self.previewView
    }
    
    private func setupRecordButtonImageView() {
        self.recordButtonImageView = UIImageView()
        self.recordButtonImageView.userInteractionEnabled = true
        let recordGestureRecognizer = CKRecordGestureRecognizer()
        recordGestureRecognizer.addTarget(self, action: Selector("recordPressed:"))
        recordButtonImageView.addGestureRecognizer(recordGestureRecognizer)
        self.recordButtonImageView.image = UIImage(named: "RecordButtonNormal")
        self.recordButtonImageView.sizeToFit()
    }
    
    private func setupGifsButton() {
        self.gifsButton = UIButton()
        self.gifsButton.frame = CGRectMake(0, 0, 44, 44)
        self.gifsButton.layer.cornerRadius = 4.0
        self.gifsButton.clipsToBounds = true
        self.gifsButton.backgroundColor = UIColor.lightGrayColor()
        self.gifsButton.addTarget(self, action: Selector("showGifs:"), forControlEvents: .TouchUpInside)
    }
    
    private func setupCancelButton() {
        self.cancelRecordingButton = LTColorPanningButton(frame: CGRectMake(0, 0, 64, 64),
            withSVG: "Close",
            withForegroundColor: kRecordingTint,
            withBackgroundColor: UIColor.whiteColor())
        self.cancelRecordingButton.addTarget(self, action: Selector("cancelRecordingPressed:"), forControlEvents: .TouchUpInside)
        self.cancelRecordingButton.alpha = 0.0
        self.cancelRecordingButton.hidden = true
    }
    
    private func setupFinishButton() {
        self.finishRecordingButton = LTColorPanningButton(frame: CGRectMake(kSCREEN_WIDTH - 64.0, 0, 64, 64),
            withSVG: "Check",
            withForegroundColor: kRecordingTint,
            withBackgroundColor: UIColor.whiteColor())
        self.finishRecordingButton.addTarget(self, action: Selector("finishRecordingPressed:"), forControlEvents: .TouchUpInside)
        self.finishRecordingButton.alpha = 0.0
        self.finishRecordingButton.hidden = true
    }
    
    private func setupCameraToggleButton() {
        self.cameraToggleButton = LTColorPanningButton(frame: CGRectMake(0, 0, 64, 64),
            withSVG: "Flip",
            withForegroundColor: kRecordingTint,
            withBackgroundColor: UIColor.whiteColor())
        self.cameraToggleButton.addTarget(self, action: Selector("cameraToggleButtonPressed:"), forControlEvents: .TouchUpInside)
        self.cameraToggleButton.center.x = kSCREEN_WIDTH * (1.0/3.0)
        
    }
    
    private func setupTorchButton() {
        self.torchButton = LTColorPanningButton(frame: CGRectMake(0, 0, 64, 64),
            withSVG: "Torch",
            withForegroundColor: kRecordingTint,
            withBackgroundColor: UIColor.whiteColor())
        self.torchButton.addTarget(self, action: Selector("torchButtonPressed:"), forControlEvents: .TouchUpInside)
        self.torchButton.center.x = kSCREEN_WIDTH * (2.0/3.0)
    }
    
    private func setupTimerView() {
        self.timerView.backgroundColor = kRecordingTint
    }
    
    // MARK: - Button Actions
    func recordPressed(gestureRecognizer: CKRecordGestureRecognizer) {
        
        if gestureRecognizer.state == .Began {
            
            if self.state == .Idle {
                self.state = .Recording
                updateStateLayout(true)
            }
            
            self.cameraController.startRecording()
            print("Begin Recording")
            
        } else if gestureRecognizer.state == .Ended {
            
            self.cameraController.pauseRecording()
            print("Paused Recording")
            
        }
    }
    
    func cancelRecordingPressed(sender: AnyObject) {
        self.cameraController.cancelRecording()
        self.state = .Idle
        self.timeViewWidthConstraint.constant = 0
        self.cancelRecordingButton.resetColor()
        self.finishRecordingButton.resetColor()
        self.torchButton.resetColor()
        self.cameraToggleButton.resetColor()
        updateStateLayout(true)
    }
    
    func cameraToggleButtonPressed(sender: AnyObject) {
        self.cameraController.toggleCamera()
        print("Toggle Camera")
        
    }
    
    func torchButtonPressed(sender: AnyObject) {
        
        if self.cameraController.toggleTorch(forceKill: false) == true {
            self.torchButton.change(kRecordingTint, andBackgroundColor: UIColor.whiteColor())
        } else {
            self.torchButton.change(kRecordingTint, andBackgroundColor: UIColor.whiteColor())
        }
       
        print("Toggle Torch")
    }
    
    func finishRecordingPressed(sender: AnyObject) {
        self.cameraController.stopRecording()
    }
    
    func showGifs(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowGifs", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEdit" {
            self.state = .Idle
            
            self.cancelRecordingButton.userInteractionEnabled = true
            self.finishRecordingButton.userInteractionEnabled = true
            
            let frames = ((sender as! NSArray) as Array)[0]
            let duration = ((sender as! NSArray) as Array)[1]
            
            let editVC = segue.destinationViewController as! CKEditViewController
            editVC.rawFrames = frames as! [CGImage]
            editVC.duration = duration as! Double
        }
    }
}

extension CKCameraViewController: CKGifCameraControllerDelegate {
    
    func controller(cameraController: CKGifCameraController, didAppendFrameNumber index: Int) {
        if index == kDEFAULT_TOTAL_FRAMES + 1 {
            self.cancelRecordingButton.userInteractionEnabled = false
            self.finishRecordingButton.userInteractionEnabled = false
        }
        
        let xOffset = kTimerIncrementWidth * CGFloat(index)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            UIView.animateWithDuration(Double(kDEFAULT_CAMERA_DURATION / Double(kDEFAULT_TOTAL_FRAMES))) { () -> Void in
                self.timeViewWidthConstraint.constant = xOffset
                
                // Update button colors
                self.cancelRecordingButton.updateColorOffest(xOffset)
                self.finishRecordingButton.updateColorOffest(xOffset)
                self.cameraToggleButton.updateColorOffest(xOffset)
                self.torchButton.updateColorOffest(xOffset)
                
                self.view.insertSubview(self.timerView, belowSubview: self.recordingView)
                self.setNeedsFocusUpdate()
            }
        }
    }
    
    func controller(cameraController: CKGifCameraController, didFinishRecordingWithFrames frames: [CGImage], withTotalDuration duration: Double) {
        print("Finished Gif")
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        self.performSegueWithIdentifier("ShowEdit", sender: [frames, duration])
    }
}

