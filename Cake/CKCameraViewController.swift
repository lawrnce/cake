//
//  ViewController.swift
//  Cake
//
//  Created by lola on 2/13/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import UIKit

class CKCameraViewController: UIViewController {

    @IBOutlet weak var toolBar: UIToolbar!

    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelRecordingButton: UIButton!
    @IBOutlet weak var finishRecordingButton: UIButton!
    
    var cameraController: CKGifCameraController!
    
    private var previewView: CKPreviewView!
    private var recordButtonImageView: UIImageView!
    private var gifsButton: UIButton!
    private var state: CameraState = .Idle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraController()
        setupPreviewView()
        setupRecordButtonImageView()
        setupGifsButton()
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
        
        self.view.addSubview(previewView)
        self.view.addSubview(self.recordButtonImageView)
        self.view.addSubview(self.gifsButton)
        updateStateLayout()
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
    private func updateStateLayout() {
        if self.state == .Idle {
            self.toolBar.hidden = false
            self.recordingView.hidden = true
            self.gifsButton.hidden = false
        } else if self.state == .Recording {
            self.toolBar.hidden = true
            self.recordingView.hidden = false
            self.gifsButton.hidden = true
        }
        setNeedsFocusUpdate()
    }
    
    
    // MARK: - Init Subviews
    private func setupCameraController() {
        // Setup Camera Controller
        self.cameraController = CKGifCameraController()
        
        do {
            if try self.cameraController.setupSession() {
                self.cameraController.delegate = self
                self.cameraController.startSession()
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
    
    // MARK: - Button Actions
    func recordPressed(gestureRecognizer: CKRecordGestureRecognizer) {
        if gestureRecognizer.state == .Began {
            
            if self.state == .Idle {
                self.state = .Recording
                updateStateLayout()
            }
            
            self.cameraController.startRecording()
            print("Begin Recording")
            
        } else if gestureRecognizer.state == .Ended {
            
            self.cameraController.pauseRecording()
            print("Paused Recording")
            
        }
    }
    
    @IBAction func cancelRecordingPressed(sender: AnyObject) {
        self.cameraController.cancelRecording()
        self.state = .Idle
        self.timeViewWidthConstraint.constant = 0
        updateStateLayout()
    }
    
    @IBAction func finishRecordingPressed(sender: AnyObject) {
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
    }
    
    func showGifs(sender: AnyObject) {
        self.performSegueWithIdentifier("ShowGifs", sender: nil)
    }
    
    
}

extension CKCameraViewController: CKGifCameraControllerDelegate {
    
    func controller(cameraController: CKGifCameraController, didAppendFrameNumber index: Int) {
        if index == kDEFAULT_TOTAL_FRAMES - 1 {
            self.cancelRecordingButton.enabled = false
            self.finishRecordingButton.enabled = false
        }
        
        let incrementWidth = Double(kSCREEN_WIDTH) / Double(kDEFAULT_TOTAL_FRAMES)
        let xOffset = incrementWidth * Double(index + 1)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            UIView.animateWithDuration(Double(5.0/90.0)) { () -> Void in
                self.timeViewWidthConstraint.constant = CGFloat(xOffset)
                self.view.insertSubview(self.timerView, belowSubview: self.recordingView)
                self.setNeedsFocusUpdate()
            }
        }
    }
    
    func controller(cameraController: CKGifCameraController, didFinishFinalizeGifToOutput fileOutput: NSURL!) {
        print("Finished Gif")
        
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
//        self.performSegueWithIdentifier("ShowEdit", sender: self)
    }
}

