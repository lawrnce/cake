//
//  CKCameraController.swift
//  Cake
//
//  Created by musashi on 12/24/15.
//  Copyright © 2015 Cake. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO
import MobileCoreServices
import CoreFoundation
//import Bolts

class CKGifCameraController: NSObject {
    
    var delegate: CKGifCameraControllerDelegate?
    var imageTarget: ImageTarget?

    var duration: Double = kDEFAULT_CAMERA_DURATION
    var framesPerSecond: Int = kDEFAULT_FRAMES_PER_SECOND
    
    var isFrontCamera: Bool = true
    var shouldTorch: Bool = false
    
    
    private var gifWriter: CKGifWriter!
    
    private var recording: Bool = false
    private var paused: Bool = false
    
    private var differenceDuration: CMTime!
    private var pausedDuration: CMTime = CMTime(seconds: 0, preferredTimescale: 600)
    private var totalRecordedDuration: CMTime!
    
    private var timePoints: [CMTime]!
    private var currentFrame: Int!
    
    private var captureSession: AVCaptureSession!
    private var frontCameraDevice: AVCaptureDevice!
    private var backCameraDevice: AVCaptureDevice!
    private var activeVideoInput: AVCaptureDeviceInput!
    
    private var frontVideoInput: AVCaptureDeviceInput!
    private var backVideoInput: AVCaptureDeviceInput!
    
    private var videoDataOutput: AVCaptureVideoDataOutput!
    private var sessionQueue: dispatch_queue_t!
    
    private var gifQueue: dispatch_queue_t!
    private var videoQueue: dispatch_queue_t!
    
    func setupSession() throws -> Bool {
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = sessionPreset()
        
        self.videoQueue = dispatch_queue_create("com.cakegifs.VideoQueue", nil)
        self.gifQueue = dispatch_queue_create("com.cakegifs.GifQueue", nil)
        
        do {
            try setupSessionInputs()
            try setupSessionOutputs()
            
            
            self.gifWriter = CKGifWriter()
            self.currentFrame = 0
            self.timePoints = [CMTime]()
            let increment = self.duration / Double(self.getTotalFrames())
            
            for frameNumber in 0 ..< self.getTotalFrames() {
                let seconds: Float64 = Float64(increment) * Float64(frameNumber)
                let time = CMTimeMakeWithSeconds(seconds, 600)
                timePoints.append(time)
            }
            
        }
        catch CKCameraError.FailedToAddInput {
            print("Failed to add camera input")
            return false
        }
        catch CKCameraError.FailedToAddOutput {
            print("Failed to add camera output")
            return false
        }
        

        
        return true
    }
    
    private func sessionPreset() -> String {
        return AVCaptureSessionPresetiFrame1280x720
    }
    
    private func setupSessionInputs() throws {
        
        sessionQueue = dispatch_queue_create("CameraSessionController Session", DISPATCH_QUEUE_SERIAL)
        
        for device in AVCaptureDevice.devices() {
            if device.position == .Front {
                self.frontCameraDevice = (device as? AVCaptureDevice)!
            } else if device.position == .Back {
                self.backCameraDevice = (device as? AVCaptureDevice)!
            }
        }
        
        do {
        
            self.frontVideoInput = try AVCaptureDeviceInput(device: self.frontCameraDevice)
            
            if self.captureSession.canAddInput(self.frontVideoInput) {
                self.captureSession.addInput(self.frontVideoInput)
            } else {
                throw CKCameraError.FailedToAddInput
            }
            
            self.activeVideoInput = self.frontVideoInput
            
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func setupSessionOutputs() throws {
        
        self.videoDataOutput = AVCaptureVideoDataOutput()
        
        self.videoDataOutput.setSampleBufferDelegate(self, queue: self.videoQueue)
        
        self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        if self.captureSession.canAddOutput(self.videoDataOutput) {
            self.captureSession.addOutput(self.videoDataOutput)
            
            self.videoDataOutput.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = .Portrait
            
            if self.videoDataOutput.connectionWithMediaType(AVMediaTypeVideo).supportsVideoStabilization {
                self.videoDataOutput.connectionWithMediaType(AVMediaTypeVideo).preferredVideoStabilizationMode = .Cinematic
            }
            
        } else {
            throw CKCameraError.FailedToAddOutput
        }
    }
    
    func startSession() {
        if !self.captureSession.running {
            dispatch_async(self.videoQueue, { () -> Void in
                self.captureSession.startRunning()
            })
        }
    }
    
    func stopSession() {
        if self.captureSession.running {
            dispatch_async(self.videoQueue, { () -> Void in
                self.captureSession.stopRunning()
            })
        }
    }
    
    private func globalQueue() -> dispatch_queue_t {
        return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    }
    
    // MARK: - Device Configuration
    func toggleTorch(forceKill forceKill: Bool) -> Bool {
        
        var isOn = Bool()
        
        let device = self.activeVideoInput.device
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if device.torchMode == .On || forceKill {
                    device.torchMode = AVCaptureTorchMode.Off
                    shouldTorch = false
                    isOn = false
                } else {
                    try device.setTorchModeOnWithLevel(1.0)
                    shouldTorch = true
                    isOn = true
                }
                device.unlockForConfiguration()
                
            } catch {
                print(error)
            }
        }
        
        return isOn
    }

    func activeCamera() -> AVCaptureDevice {
        return self.activeVideoInput.device
    }
    
    func toggleCamera() {
        self.captureSession.removeInput(self.activeVideoInput)
        
        do {
            if self.activeVideoInput.device == self.frontCameraDevice {
                self.activeVideoInput = nil
                self.activeVideoInput = try AVCaptureDeviceInput(device: self.backCameraDevice)
                self.isFrontCamera = false
                
            } else if self.activeVideoInput.device == self.backCameraDevice {
                self.activeVideoInput = nil
                self.activeVideoInput = try AVCaptureDeviceInput(device: self.frontCameraDevice)
                self.isFrontCamera = true
            }
            
            if self.captureSession.canAddInput(self.activeVideoInput) {
                self.captureSession.addInput(self.activeVideoInput)
            } else {
                throw CKCameraError.FailedToAddInput
            }
            
            self.videoDataOutput.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = .Portrait
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
//        if let device = self.activeVideoInput.device {
//            do {
//                try! device.lockForConfiguration()
//                if device.focusPointOfInterestSupported{
//                    //Add Focus on Point
////                    device.focusPointOfInterest = Point
//                    
//                    
//                    device.focusMode = AVCaptureFocusMode.AutoFocus
//                }
//                
//                if device.exposurePointOfInterestSupported{
//                    //Add Exposure on Point
////                    device.exposurePointOfInterest = Point
//                    device.exposureMode = AVCaptureExposureMode.AutoExpose
//                }
//                device.unlockForConfiguration()
//            }
//        }
        
        if self.shouldTorch {
            
            let seconds = 0.5
            let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
            let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.toggleTorch(forceKill: false)
                
            })
        }
    }
    
    // MARK: - Capture Methods
    func isRecording() -> Bool {
        return self.recording
    }
    
    func startRecording() {
        if !self.isRecording() {
            self.recording = true
            self.paused = false
        }
    }
    
    func pauseRecording() {
        if self.isRecording() == true {
            self.recording = false
            self.paused = true
        }
    }
    
    func cancelRecording() {
        toggleTorch(forceKill: true)
        self.totalRecordedDuration = nil
        self.differenceDuration = nil
        self.pausedDuration = CMTime(seconds: 0, preferredTimescale: 600)
        self.recording = false
        self.paused = false
        self.currentFrame = 0
        self.gifWriter = nil
        self.gifWriter = CKGifWriter()
    }
    
    func stopRecording() {
        toggleTorch(forceKill: true)
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        self.delegate?.controller(self, didFinishRecordingWithFrames: self.gifWriter.bitmaps, withTotalDuration: self.totalRecordedDuration!.seconds)
        self.totalRecordedDuration = nil
        self.differenceDuration = nil
        self.pausedDuration = CMTime(seconds: 0, preferredTimescale: 600)
        self.recording = false
        self.paused = false
        self.currentFrame = 0
        
        
        self.gifWriter = nil
        self.gifWriter = CKGifWriter()
    }
    
    func returnedOrientation() -> AVCaptureVideoOrientation {
        var videoOrientation: AVCaptureVideoOrientation!
        let orientation = UIDevice.currentDevice().orientation

        switch orientation {
        case .Portrait:
            videoOrientation = .Portrait
        case .PortraitUpsideDown:
            videoOrientation = .PortraitUpsideDown
        case .LandscapeLeft:
            videoOrientation = .LandscapeRight
        case .LandscapeRight:
            videoOrientation = .LandscapeLeft
        case .FaceDown, .FaceUp, .Unknown:
            videoOrientation = .Portrait
        }
        return videoOrientation
    }
    
    private func getDelayTime() -> Float {
        return Float(self.duration) / Float(getTotalFrames())
    }
    
    private func getTotalFrames() -> Int {
        return Int(self.framesPerSecond * Int(self.duration))
    }
    
}

extension CKGifCameraController : AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        if (captureOutput == self.videoDataOutput) {
            
            let previewImage = getCroppedPreviewImageFromBuffer(sampleBuffer)
            self.imageTarget?.setImage(previewImage)
            
            if self.recording {
                
                if self.differenceDuration == nil {
                    self.differenceDuration = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                } else if self.pausedDuration > CMTime(seconds: 0, preferredTimescale: 600) {
                    self.differenceDuration = self.differenceDuration + self.pausedDuration
                    self.pausedDuration = CMTime(seconds: 0, preferredTimescale: 600)
                }
                
                self.totalRecordedDuration = CMSampleBufferGetPresentationTimeStamp(sampleBuffer) - self.differenceDuration
                
                print(self.totalRecordedDuration.seconds)
                
                if self.totalRecordedDuration >= self.timePoints[self.currentFrame] {
                    
                    self.gifWriter.appendFrame(previewImage)
                    delegate?.controller(self, didAppendFrameNumber: self.gifWriter.frameCount)
                    
                    if (self.timePoints.count - 1) == self.currentFrame {
                        self.stopRecording()
                    } else {
                        self.currentFrame = self.currentFrame + 1
                    }
                }
                
            } else if self.paused {
                
                if self.totalRecordedDuration != nil && self.differenceDuration != nil {
                    self.pausedDuration = CMSampleBufferGetPresentationTimeStamp(sampleBuffer) - self.totalRecordedDuration - self.differenceDuration
                    
                }
                
            }
        }
    }
    
    // MARK: - Preview Image Methods
    private func getCroppedPreviewImageFromBuffer(buffer: CMSampleBuffer) -> CIImage {
        let imageBuffer: CVPixelBufferRef = CMSampleBufferGetImageBuffer(buffer)!
        let sourceImage: CIImage = CIImage(CVPixelBuffer: imageBuffer).copy() as! CIImage
        let croppedSourceImage = sourceImage.imageByCroppingToRect(CGRectMake(0, 0, 720, 720))
        
        let transform: CGAffineTransform!
        
        if self.activeCamera() == self.frontCameraDevice {
            transform = CGAffineTransformMakeScale(-1.0, 1.0)
        } else {
            transform = CGAffineTransformMakeScale(1.0, 1.0)
        }
        
        let correctedImage = croppedSourceImage.imageByApplyingTransform(transform)
        
        return correctedImage
    }}

// MARK: - Protocol CKCaptureSessionDelegate
protocol CKGifCameraControllerDelegate {
    func controller(cameraController: CKGifCameraController, didAppendFrameNumber index: Int)
    func controller(cameraController: CKGifCameraController, didFinishRecordingWithFrames frames: [CGImage], withTotalDuration duration: Double)
}