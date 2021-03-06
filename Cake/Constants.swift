//
//  Constants.swift
//  Cake
//
//  Created by lola on 2/13/16.
//  Copyright © 2016 CakeGifs. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

// MARK: - Tokens
let MixpanelToken = "6df839eb7575f19a5f85be73dc0d6a28"

// MARK: - Color
let kLightTint = UIColor(rgba: "#FF6699")
let kRecordingTint = UIColor(rgba: "#7DF9FF")

let kTorchSelectedTint = UIColor(rgba: "#FF0099")

// MARK: - File Management
let kSHARED_CONTAINER = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.cake.CakeExtensionSharedContainer")
let kSHARED_GIF_DIRECTORY = kSHARED_CONTAINER?.URLByAppendingPathComponent("Gifs")

// MARK: - General UI Constants
let kSCREEN_WIDTH = UIScreen.mainScreen().bounds.width
let kSCREEN_HEIGHT = UIScreen.mainScreen().bounds.height

let kCameraButtonSpace = (kSCREEN_WIDTH - 4.0 * 64.0) / 3.0
let kToggleButtonFrameOriginX = 64.0 + kCameraButtonSpace
let kTorchButtonFrameOriginX = 64.0 + kCameraButtonSpace + 64.0 + kCameraButtonSpace

// MARK: - Camera Constants
enum CameraState {
    case Idle
    case Recording
}

let kDEFAULT_CAMERA_DURATION = 3.0
let kDEFAULT_FRAMES_PER_SECOND = 16
let kDEFAULT_TOTAL_FRAMES = Int(Int(kDEFAULT_CAMERA_DURATION) * Int(kDEFAULT_FRAMES_PER_SECOND))
let kTimerIncrementWidth = CGFloat(Double(kSCREEN_WIDTH) / Double(kDEFAULT_TOTAL_FRAMES))

// MARK: - Gifs Detail View Controller
let kDetailButtonWidth = CGFloat(60.0)
let kDetailButtonSpace = (kSCREEN_WIDTH - 2.0 * kDetailButtonWidth) / 3.0
let kDetailButtonCenterY = (kSCREEN_WIDTH + kSCREEN_HEIGHT - 64.0) / 2.0
let kCopyButtonFrameOriginX = kDetailButtonSpace
//let kActionButtonFrameOriginX = kCopyButtonFrameOriginX + kDetailButtonWidth + kDetailButtonSpace
let kDeleteButtonFrameOriginX = kCopyButtonFrameOriginX + kDetailButtonWidth + kDetailButtonSpace

// MARK: - Build Constants
let kGIFS_COLLECTION_VIEW_HEIGHT = (kSCREEN_HEIGHT - (44.0 * 2.0)) * 2.0/3.0

// MARK: - Notification
let GIF_FINALIZED = "com.cakegifs.GifFinalized"
let ShowOriginalDetail = "com.cakegifs.ShowOriginalDetail"
let ShowMashUpDetail = "com.cakegifs.ShowMashUpDetail"

// MARK: - Reuse Identifier
let editCollectionCellIdentifier = "editCollectionCellIdentifier"


// MARK: - Error Domains
enum CKCameraError : ErrorType {
    case FailedToAddInput
    case FailedToAddOutput
}