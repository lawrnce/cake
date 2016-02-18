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

// MARK: - Color
let kRecordingTint = UIColor(rgba: "#FF6699")
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

let kDEFAULT_CAMERA_DURATION = 4.0
let kDEFAULT_FRAMES_PER_SECOND = 24
let kDEFAULT_TOTAL_FRAMES = Int(Int(kDEFAULT_CAMERA_DURATION) * Int(kDEFAULT_FRAMES_PER_SECOND))
let kTimerIncrementWidth = CGFloat(Double(kSCREEN_WIDTH) / Double(kDEFAULT_TOTAL_FRAMES))

// MARK: - Notification
let GIF_FINALIZED = "com.cakegifs.GifFinalized"

// MARK: - Reuse Identifier
let editCollectionCellIdentifier = "editCollectionCellIdentifier"


// MARK: - Error Domains
enum CKCameraError : ErrorType {
    case FailedToAddInput
    case FailedToAddOutput
}