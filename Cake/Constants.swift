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

// MARK: - General UI Constants
let kSCREEN_WIDTH = UIScreen.mainScreen().bounds.width
let kSCREEN_HEIGHT = UIScreen.mainScreen().bounds.height

// MARK: - Camera Constants
enum CameraState {
    case Idle
    case Recording
}

let kDEFAULT_CAMERA_DURATION = 5.0
let kDEFAULT_FRAMES_PER_SECOND = 18
let kDEFAULT_TOTAL_FRAMES = 90



// MARK: - Error Domains
enum CKCameraError : ErrorType {
    case FailedToAddInput
    case FailedToAddOutput
}